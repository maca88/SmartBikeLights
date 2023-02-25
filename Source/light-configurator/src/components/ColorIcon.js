import React from 'react';
import { styled } from '@mui/material/styles';

const Icon = styled('div')(() => ({
  width: '24px',
  height: '24px',
  backgroundImage: 'none',
  display: 'inline-flex',
  verticalAlign: 'bottom',
  boxShadow: '0 4px 6px rgba(50, 50, 93, 0.11), 0 1px 3px rgba(0, 0, 0, 0.08)',
  borderWidth: 0,
  borderRadius: 4,
  padding: 0
}));

const IconComponent = ({ color, ...props }) => {
  const hexColor = '#' + color.toString(16).padStart(6, '0');
  return (
    <Icon
      variant="contained"
      style={{backgroundColor:hexColor}}
      {...props}
     />);
};

export default IconComponent;
