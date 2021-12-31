import Accordion from '@mui/material/Accordion';
import { styled } from '@mui/material/styles';

export default styled(Accordion)(({ theme }) => ({
  border: `1px solid ${theme.palette.divider}`,
  boxShadow: 'none',
  '&:not(:last-child)': {
    borderBottom: 0,
  },
  '&:before': {
    display: 'none',
  },
  '& .MuiAccordion-root.Mui-expanded': {
    margin: 'auto'
  },
  '&.MuiAccordion-root': {
    margin: 0
  }
}));