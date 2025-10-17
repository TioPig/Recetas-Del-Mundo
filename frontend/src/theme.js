import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  typography: {
    fontFamily: 'Lato, Roboto, Arial, sans-serif',
    h1: { fontFamily: 'Lato, Roboto, Arial, sans-serif', fontWeight: 900 },
    h2: { fontFamily: 'Lato, Roboto, Arial, sans-serif', fontWeight: 900 },
    h3: { fontFamily: 'Lato, Roboto, Arial, sans-serif', fontWeight: 900 },
    h4: { fontFamily: 'Lato, Roboto, Arial, sans-serif', fontWeight: 900 },
    h5: { fontFamily: 'Lato, Roboto, Arial, sans-serif', fontWeight: 900 },
    h6: { fontFamily: 'Lato, Roboto, Arial, sans-serif', fontWeight: 700 },
    subtitle1: { fontFamily: 'Lato, Roboto, Arial, sans-serif', fontWeight: 700 },
    body1: { fontFamily: 'Lato, Roboto, Arial, sans-serif', fontWeight: 700 },
    body2: { fontFamily: 'Lato, Roboto, Arial, sans-serif', fontWeight: 400 },
  },
  components: {
    MuiTypography: {
      styleOverrides: {
        root: {
          // default will be Lato; blue titles will override to Roboto where needed
        }
      }
    }
  }
});

export default theme;
