import React, { useEffect, useState } from 'react';
import { getCategorias } from '../api';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import { Link as RouterLink } from 'react-router-dom';

export default function Categorias(){
  const [cats, setCats] = useState([]);

  useEffect(()=>{
    getCategorias()
      .then(r=>{
        const raw = r && r.data ? r.data : r;
        const list = Array.isArray(raw) ? raw : (Array.isArray(raw?.items) ? raw.items : (Array.isArray(raw?.categorias) ? raw.categorias : []));
        setCats(list);
      })
      .catch(e=> console.error(e));
  },[]);

  return (
    <>
      <Box sx={{ backgroundColor: '#F6F0E0', py: 3, mb: 3 }}>
        <Container maxWidth="xl">
          <Typography variant="h4" align="center" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 900, color: '#99682E', fontSize: '3.75rem' }}>Categorías</Typography>
        </Container>
      </Box>
      <Container sx={{ py: 4 }}>
        <Box sx={{ textAlign: 'center' }}>
        {cats.length === 0 ? (
          <Typography>No hay categorías para mostrar.</Typography>
        ) : (
          cats.map(c => {
            const catId = c.idCat ?? c.idCategoria ?? c.id;
            return (
              <Box key={catId || c.nombre} sx={{ display: 'inline-block', width: { xs: '100%', sm: '48%', md: '25%' }, boxSizing: 'border-box', p: 1, textAlign: 'center' }}>
                <ButtonBase component={RouterLink} to={`/categorias/${catId}`} sx={{ display: 'block', width: '100%', textAlign: 'inherit', borderRadius: 1 }}>
                  <Box component="img" src={c.urlImagen || 'https://placehold.co/300x200?text=No+Image'} alt={c.nombre} sx={{ width: '100%', maxHeight: 120, objectFit: 'cover', borderRadius: 1 }} onError={(e) => { e.target.src = 'https://placehold.co/300x200?text=No+Image'; }} />
                  <Typography align="center" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700, mt: 1, color: '#969696' }}>{c.nombre}</Typography>
                </ButtonBase>
              </Box>
            );
          })
        )}
        </Box>
      </Container>
    </>
  );
}
