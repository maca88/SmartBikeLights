import { observer } from 'mobx-react-lite';
import FormControlLabel from '@mui/material/FormControlLabel';
import Checkbox from '@mui/material/Checkbox';

export default observer(({ label, value, setter }) => {
  return (
    <FormControlLabel
      sx={{ marginRight: 0 }}
      control={<Checkbox checked={value} onChange={(e) => setter(e.target.checked)} />}
      label={label}
    />
  );
});