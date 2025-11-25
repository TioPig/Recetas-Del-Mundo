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
      <Box sx={{ 
        background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)', 
        py: { xs: 4, md: 6 }, 
        mb: 4 
      }}>
        <Container maxWidth="xl" sx={{ maxWidth: '1400px' }}>
          <Typography 
            variant="h3" 
            align="center" 
            sx={{ 
              fontFamily: 'Lato, sans-serif', 
              fontWeight: 900, 
              color: 'white',
              textShadow: '2px 2px 4px rgba(0,0,0,0.2)',
              fontSize: { xs: '2rem', sm: '2.5rem', md: '3rem' }
            }}
          >
            Países
          </Typography>
          <Typography
            align="center"
            sx={{
              fontFamily: 'Open Sans, sans-serif',
              color: 'white',
              mt: 1,
              fontSize: { xs: '0.95rem', sm: '1rem', md: '1.1rem' },
              textShadow: '1px 1px 2px rgba(0,0,0,0.1)'
            }}
          >
            Descubre recetas de todo el mundo
          </Typography>
        </Container>
      </Box>
      <Container maxWidth="xl" sx={{ py: { xs: 3, md: 4 }, maxWidth: '1400px' }}>
        <Box sx={{ textAlign: 'center' }}>
          {paises.length === 0 ? (
            <Box sx={{
              textAlign: 'center',
              py: 6,
              backgroundColor: '#F7FAFC',
              borderRadius: 3
            }}>
              <Typography sx={{ 
                color: '#718096', 
                fontFamily: 'Open Sans, sans-serif', 
                fontSize: { xs: '1rem', md: '1.1rem' }
              }}>
                No hay países para mostrar.
              </Typography>
            </Box>
          ) : (
            paises.map(p=> (
              <Box 
                key={p.idPais} 
                sx={{ 
                  display: 'inline-block', 
                  width: { xs: '100%', sm: '48%', md: '25%' }, 
                  boxSizing: 'border-box', 
                  p: { xs: 1, sm: 1.5 }, 
                  textAlign: 'center' 
                }}
              >
                <ButtonBase 
                  component={RouterLink} 
                  to={`/paises/${p.idPais}`} 
                  sx={{ 
                    display: 'block', 
                    width: '100%', 
                    textAlign: 'inherit',
                    borderRadius: 3,
                    overflow: 'hidden',
                    boxShadow: '0 4px 12px rgba(102, 126, 234, 0.15)',
                    transition: 'transform 0.3s ease, box-shadow 0.3s ease',
                    border: '2px solid #F7FAFC',
                    '&:hover': {
                      transform: 'translateY(-8px)',
                      boxShadow: '0 8px 24px rgba(102, 126, 234, 0.3)',
                      borderColor: '#667EEA'
                    }
                  }}
                >
                  <Box sx={{
                    width: '100%',
                    height: { xs: 200, sm: 220 },
                    backgroundColor: 'white',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    padding: 2
                  }}>
                    <Box 
                      component="img" 
                      src={p.urlImagen || 'https://placehold.co/300x200?text=No+Image'} 
                      alt={p.nombre} 
                      sx={{ 
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover',
                        borderRadius: 2,
                        border: '3px solid rgba(102, 126, 234, 0.4)'
                      }} 
                      onError={(e)=>{ e.target.src='https://placehold.co/300x200?text=No+Image'; }} 
                    />
                  </Box>
                  <Box sx={{ backgroundColor: 'white', p: { xs: 1.5, sm: 2 } }}>
                    <Typography 
                      align="center" 
                      sx={{ 
                        fontFamily: 'Lato, sans-serif', 
                        fontWeight: 900, 
                        color: '#667EEA',
                        fontSize: { xs: '1rem', sm: '1.1rem' }
                      }}
                    >
                      {p.nombre}
                    </Typography>
                  </Box>
                </ButtonBase>
              </Box>
            ))
          )}
        </Box>
      </Container>
    </>
  );
}
