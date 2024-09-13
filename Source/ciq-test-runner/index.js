#!/usr/bin/env node

import process from 'process';
import fs from 'fs';
import os from 'os';
import { Command } from 'commander'
import { spawn } from 'child_process';


const writeLog = (text, verbose) => {
  if (verbose) {
    console.debug(text);
  }
}

const executeCommand = (command, args, onStdoutData = null, onStderrData = null, successCode = 0) => {
  return new Promise((resolve, reject) => {
    const process = spawn(command, args);
    if (onStdoutData) {
      process.stdout.on('data', onStdoutData);
    }

    if (onStderrData) {
      process.stderr.on('data', onStderrData);
    }

    process.on('close', (code) => {
      if (code != successCode) {
        reject(code)
        return;
      }

      resolve();
    });
  });
};

class DeviceResult {
  tests = {};
  summary = {
    total: 0,
    passed: 0,
    failed: 0,
    errors: 0
  };

  addTestOutput(testName, value) {
    const data = this.tests[testName] = this.tests[testName] || {};
    if (data.output) {
      data.output += `\r\n${value}`;
    } else {
      data.output = value
    }
  }

  addTestStatus(testName, value) {
    this.tests[testName] = this.tests[testName] || {};
    this.tests[testName].status = value;
  }
}

class TestResults {

  deviceResults = {};
  summary = {
    total: 0,
    passed: 0,
    failed: 0,
    errors: 0
  };

  addResult(device, deviceResults) {
    this.deviceResults[device] = deviceResults;
    const summary = this.summary;
    summary.total += deviceResults.summary.total;
    summary.passed += deviceResults.summary.passed;
    summary.failed += deviceResults.summary.failed;
    summary.errors += deviceResults.summary.errors;
  }

  get isSuccessful() {
    return this.summary.total == this.summary.passed;
  }

  toString() {
    const summary = this.summary;
    const result = this.isSuccessful ? 'PASSED' : 'FAILED';

    let text = `${result} (total=${summary.total} passed=${summary.passed}, failed=${summary.failed}, errors=${summary.errors})`;
    if (this.isSuccessful) {
      return text;
    }

    for (let [device, results] of Object.entries(this.deviceResults)) {
      if (results.summary.total === results.summary.passed) {
        continue;
      }

      text += '\r\n\r\n';
      text += '-'.repeat(80);
      text += `\r\nDEVICE ${device}:`;
      for (let [testName, testData] of Object.entries(results.tests)) {
        if (testData.status === 'PASS') {
          continue;
        }

        text += `\r\n${testName} - ${testData.status}:`;
        text += `\r\n${testData.output}`;
      }

      text += '\r\n';
      text += '-'.repeat(80);
    }

    return text;
  }
}

class TestRunner {

  device;
  sdkPath;
  keyPath;
  basePath;

  constructor(device, sdkPath, keyPath, basePath) {
    this.device = device;
    this.sdkPath = sdkPath;
    this.keyPath = keyPath;
    this.basePath = basePath;
  }

  async runTests(verbose) {
    const outputFile = `${os.tmpdir()}/test_${this.device}.prg`;


    writeLog(`Start building for device ${this.device}...`, verbose);
    await executeCommand(
      'java',
      [
        '-Xms1g',
        '-Dfile.encoding=UTF-8',
        '-Dapple.awt.UIElement=true',
        '-jar',
        `${this.sdkPath}bin/monkeybrains.jar`,
        '-o',
        outputFile,
        '-f',
        `${this.basePath}/monkey.jungle`,
        '-y',
        `${this.keyPath}`,
        '-d',
        `${this.device}`,
        '-w',
        '--unit-test'
      ],
      null,
      (data) => {
        const text = data.toString().trim();
        if (text.startsWith('WARNING')) {
          writeLog(text, verbose);
        } else {
          console.error(text);
        }
      }
    )

    writeLog('Build was successful', verbose);
    writeLog(`Running tests for device ${this.device}...`, verbose);

    const result = new DeviceResult();
    let currentTestName = null;
    await executeCommand(
      'cmd',
      ['/c', `${this.sdkPath}/bin/monkeydo.bat`, outputFile, this.device, '/t'],
      (data) => {
        const text = data.toString().trim();
        writeLog(text, verbose);

        if (text.startsWith('---------------') || // Before test is executed
            text.startsWith('===============') // After all tests are executed
          ) {
          return;
        }

        let testMatch = text.match(/^Executing test\s+(.+?)\.\.\.$/);
        if (testMatch) {
          [currentTestName] = testMatch.slice(1);
          return;
        }

        if (!text.startsWith('RESULTS') || !text.match(/RESULTS[\s\r\n]*Test\:\s+Status\:/)) {
          if (currentTestName !== null) {
            result.addTestOutput(currentTestName, text);
          }

          return;
        }

        const lines = text.split('\n');
        for (let i = 2; i < lines.length; i++) {
          const line = lines[i].trim();
          if (line.startsWith('Ran')) {
            const totalTests = line.match(/^Ran (\d+) tests$/);
            if (totalTests) {
              result.summary.total = parseInt(totalTests[1]);
            }
          } else if (line.startsWith('FAILED') || line.startsWith('PASSED')) {
              const [_, passed, failed, errors] = line.match(/passed=(\d+), failed=(\d+), errors=(\d+)/);
              result.summary.passed = parseInt(passed);
              result.summary.failed = parseInt(failed);
              result.summary.errors = parseInt(errors);
          } else {
              testMatch = line.match(/^(.+?)\s+(PASS|ERROR|FAIL)$/);
              if (testMatch) {
                  const [testName, status] = testMatch.slice(1);
                  result.addTestStatus(testName, status);
              }
          }
        }
      }
    );

    writeLog(`Tests completed ${JSON.stringify(result, null, 2)}`, verbose);

    return result;
  }
}

const program = new Command()
  .version('1.0.0', '-v, --version', 'output the current version');

program
  .command('test')
  .description('run CIQ unit tests')
  .argument('[devices...]', 'The garmin devices to run the unit tests')
  .requiredOption('-k, --keyPath [filePath]', 'Garmin CIQ key')
  .option('-v, --verbose', 'Provides more detailed output')
  .option('-b, --baseDirectory [path]', 'base directory path that will be used to resolving relative paths for include directive. If not specified, the base directory will be the folder where the command is executed')
  .action(async (devices, options) => {

    const basePath = options.baseDirectory || '.';
    const sdkFile = process.env.APPDATA + '/Garmin/ConnectIQ/current-sdk.cfg';
    const sdkPath = fs.readFileSync(sdkFile, 'utf8');
    const keyPath = options.keyPath;

    writeLog('Starting simulator...', options.verbose);
    const simulator = spawn(`${sdkPath}/bin/simulator.exe`);

    const results = new TestResults();
    for (let device of devices) {
      const runner = new TestRunner(device, sdkPath, keyPath, basePath);
      const deviceResults = await runner.runTests(options.verbose);
      results.addResult(device, deviceResults);
    }

    console.info(results.toString());

    simulator.kill();
  });

let stdin = '';

if (process.stdin.isTTY) {
  program.parse(process.argv);
}
else {
  process.stdin.on('readable', function() {
      const chunk = this.read();
      if (chunk !== null) {
        stdin += chunk;
      }
  });
  process.stdin.on('end', function() {
    program.parse(process.argv);
  });
}
