import React from 'react';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';

export default function Footer(){
  return (
  <Box component="footer" sx={{ backgroundColor: '#F75442', color: '#fff', py: 3, mt: 2 }}>
      <Container>
        <Box sx={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap' }}>
          <Box sx={{ flex: '0 0 20%' }}>
            <Typography variant="h6" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>Recetas</Typography>
            <Typography sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Del mundo</Typography>
          </Box>
          <Box sx={{ flex: '1 1 80%' }}>
            <Typography sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>{new Date().getFullYear()}, Recetas del mundo - un sitio donde podrás encontrar la receta perfecta para esa ocasión.</Typography>
          </Box>
        </Box>
      </Container>
    </Box>
  );
}
