import firebase from 'firebase/compat/app';
import { getFirestore, collection, runTransaction , addDoc, doc, setDoc, deleteDoc, Timestamp, getDocs } from "firebase/firestore"
import 'firebase/compat/auth';
import { makeAutoObservable } from 'mobx';

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyAsIIaVeWT6yJhPXLYRpNdh5gb_qBZBcks",
  authDomain: "lightsconfigurator.firebaseapp.com",
  projectId: "lightsconfigurator",
  storageBucket: "lightsconfigurator.appspot.com",
  messagingSenderId: "786308417945",
  appId: "1:786308417945:web:8302200058c97b643feb08"
};

class FirebaseService {

  app = null;
  db = null;
  currentUser = null;
  userConfigurations = [];
  selectedConfiguration = null;

  constructor() {
    makeAutoObservable(this, {
    });
  }

  isSignedIn = () => this.currentUser != null;

  signOut = () =>  {
    firebase.auth().signOut();
  }

  initialize = () => {
    this.app = firebase.initializeApp(firebaseConfig);
    this.db = getFirestore(this.app);
    firebase.auth().onAuthStateChanged(user => {
      this.setUserAsync(user);
    });
  }

  subscribeOnUserChanged(func) {
    return firebase.auth().onAuthStateChanged(func);
  }

  setCurrentUser = (value) => {
    this.currentUser = value;
  }

  setSelectedConfiguration = (value) => {
    this.selectedConfiguration = value;
  }

  setUserConfigurations = (value) => {
    this.userConfigurations = value;
  }

  saveConfigurationAsync = async (name, value) => {
    if (!this.currentUser) {
      return;
    }

    try {
      const document = await addDoc(collection(this.db, 'users', this.currentUser.uid, 'configurations'), {
        name: name,
        value: value,
        createdAt: Timestamp.now(),
        lastModifiedAt : Timestamp.now()
      });
      await this.refreshConfigurationsAsync();

      return document.id;
    } catch (e) {
      alert(e)
    }
  }

  updateConfigurationAsync = async (id, name, value) => {
    if (!this.currentUser) {
      return;
    }

    try {
      await setDoc(doc(this.db, 'users', this.currentUser.uid, 'configurations', id), {
        name: name,
        value: value,
        lastModifiedAt : Timestamp.now()
      }, {
        mergeFields: ['name', 'value', 'lastModifiedAt']
      });
      await this.refreshConfigurationsAsync();
    } catch (e) {
      alert(e)
    }
  }

  deleteConfigurationAsync = async (id) => {
    if (!this.currentUser) {
      return;
    }

    try {
      await deleteDoc(doc(this.db, 'users', this.currentUser.uid, 'configurations', id));
      await this.refreshConfigurationsAsync();
    } catch (e) {
      alert(e)
    }
  }

  setUserAsync = async (user) => {
    this.setCurrentUser(user);
    this.setUserConfigurations([]);
    this.setSelectedConfiguration(null);
    if (!user) {
      return;
    }

    const userRef = doc(this.db, 'users', user.uid);
    try {
      await runTransaction(this.db, async (transaction) => {
        const userDocument = await transaction.get(userRef);
        if (!userDocument.exists()) {
          transaction.set(userRef, {
            email: user.email,
            createdAt: Timestamp.now(),
            lastAccessedAt: Timestamp.now()
          });
        } else {
          transaction.update(userRef, {
            lastAccessedAt: Timestamp.now()
          });
        }
      });
    } catch (e) {
      alert(e)
    }


    await this.refreshConfigurationsAsync();
  }

  refreshConfigurationsAsync = async () => {
    this.setUserConfigurations(await this.getConfigurations());
  }

  getConfigurations = async () => {
    const results = [];
    if (!this.currentUser) {
      return results;
    }

    const snapshot = await getDocs(collection(this.db, 'users', this.currentUser.uid, 'configurations'));
    snapshot.forEach(doc => {
      results.push({ id: doc.id, ...doc.data() });
    });

    return results;
  }
}

const instance = new FirebaseService();

export default instance;
