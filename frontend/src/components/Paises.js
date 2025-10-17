import React, { useEffect, useState } from 'react';
import { getPaises } from '../api';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import { Link as RouterLink } from 'react-router-dom';

export default function Paises(){
  const [paises, setPaises] = useState([]);

  useEffect(()=>{
    getPaises().then(r=> setPaises(r.data || [])).catch(e=> console.error(e));
  },[]);

  return (
    <>
      <Box sx={{ backgroundColor: '#F6F0E0', py: 3, mb: 3 }}>
        <Container maxWidth="xl" sx={{ maxWidth: '1400px' }}>
          <Typography variant="h4" align="center" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 900, color: '#99682E', fontSize: '3.75rem' }}>Países</Typography>
        </Container>
      </Box>
      <Container maxWidth="xl" sx={{ py: 4, maxWidth: '1400px' }}>
        <Box sx={{ textAlign: 'center' }}>
          {paises.map(p=> (
          <Box key={p.idPais} sx={{ display: 'inline-block', width: { xs: '100%', sm: '48%', md: '25%' }, boxSizing: 'border-box', p: 1, textAlign: 'center' }}>
            <ButtonBase component={RouterLink} to={`/paises/${p.idPais}`} sx={{ display: 'block', width: '100%', textAlign: 'inherit', borderRadius: 1 }}>
              <Box component="img" src={p.urlImagen || 'https://placehold.co/300x200?text=No+Image'} alt={p.nombre} sx={{ width: '100%', maxHeight: 120, objectFit: 'cover', borderRadius: 1 }} onError={(e)=>{ e.target.src='https://placehold.co/300x200?text=No+Image'; }} />
              <Typography align="center" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700, mt: 1, color: '#969696' }}>{p.nombre}</Typography>
            </ButtonBase>
          </Box>
          ))}
        </Box>
      </Container>
    </>
  );
}
