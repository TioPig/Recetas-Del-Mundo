import React from 'react';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import { useEffect, useState } from 'react';
import { getPaises, getRecetasTrending } from '../api';
import { Link as RouterLink } from 'react-router-dom';

export default function Home(){
  const [paisesList, setPaisesList] = useState([]);
  const [featured, setFeatured] = useState(null);

  useEffect(()=>{
    getPaises().then(r=> setPaisesList(Array.isArray(r.data)?r.data:[])).catch(()=>{});
    // use trending endpoint to get a featured recipe
    getRecetasTrending(1).then(r=>{
      const data = r && r.data ? r.data : r;
      const list = Array.isArray(data) ? data : (Array.isArray(data?.recetas) ? data.recetas : (Array.isArray(data?.items) ? data.items : []));
      if(list.length) setFeatured(list[0]);
    }).catch(()=>{});
  },[]);
  return (
    <Box>
      {/* Hero */}
      <Box sx={{ backgroundImage: `url('/img/fondo_inicio.jpg')`, backgroundRepeat: 'repeat', backgroundSize: '150px', py: 6 }}>
        <Container sx={{ display: 'flex', alignItems: 'center', gap: 4, flexWrap: { xs: 'wrap', md: 'nowrap' } }}>
          <Box sx={{ flex: '1 1 500px' }}>
            <Typography variant="h3" component="h1" sx={{ color: 'rgb(47, 66, 149)', fontFamily: 'Roboto, sans-serif', fontWeight: 700 }}>Bienvenid@</Typography>
            <Typography sx={{ color: 'rgb(153, 104, 46)', fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>¡Bienvenido a nuestra pagina de comidas! Aquí podrás descubrir deliciosas opciones de diferentes países para satisfacer tus antojos culinarios. ¡Buen provecho!</Typography>
          </Box>
          <Box sx={{ flex: '0 0 420px' }}>
            <Box component="img" src="/img/cheems-waso.png" alt="" sx={{ width: '100%', maxWidth: 420 }} />
          </Box>
        </Container>
      </Box>

      {/* Como funciona */}
      <Box sx={{ backgroundColor: '#F9E9AE', py: 6 }}>
        <Container>
        <Box sx={{ width: '100%', my: 3, display: 'flex', justifyContent: 'center' }}>
          <Box sx={{ width: '80%', borderTop: '2px solid rgba(153,104,46,0.25)' }} />
        </Box>
          <Stack spacing={3} alignItems="center">
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <CheckCircleIcon sx={{ color: '#99682E', fontSize: 28 }} />
              <Typography variant="h5" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>Como funciona</Typography>
              <CheckCircleIcon sx={{ color: '#99682E', fontSize: 28 }} />
            </Box>

            <Box sx={{ display: 'flex', gap: 3, flexWrap: 'wrap', justifyContent: 'center', width: '100%' }}>
              <Box sx={{ textAlign: 'center', flexBasis: { xs: '100%', md: '30%' } }}>
                <Box component="img" src="/img/Eat and Enjoy-8.png" alt="acceso" sx={{ maxWidth: 150 }} />
                <Typography variant="h6" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>¿De donde puedes Acceder?</Typography>
                <Typography color="text.secondary" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 400 }}>Desde todas las partes del mundo, sin importar donde seas</Typography>
              </Box>

              <Box sx={{ textAlign: 'center', flexBasis: { xs: '100%', md: '30%' } }}>
                <Box component="img" src="/img/Meal-icon-8.png" alt="de-donde" sx={{ maxWidth: 150 }} />
                <Typography variant="h6" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>¿De donde?</Typography>
                <Typography color="text.secondary" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 400 }}>Gracias a la gran comunidad culinaria, podemos traer recetas desde cualquier parte del mundo</Typography>
              </Box>

              <Box sx={{ textAlign: 'center', flexBasis: { xs: '100%', md: '30%' } }}>
                <Box component="img" src="/img/Recurso 41-8.png" alt="ayuda" sx={{ maxWidth: 150 }} />
                <Typography variant="h6" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>¿Puedo Ayudar?</Typography>
                <Typography color="text.secondary" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 400 }}>claro, solo necesitas acceder y podras aportar a esta gran comunidad</Typography>
              </Box>
            </Box>
          </Stack>
        </Container>
      </Box>

      {/* RECETAS */}
      <Container sx={{ py: 4 }}>
        <Box textAlign="center">
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, justifyContent: 'center' }}>
            <Box sx={{ flex: '1 1 30%', maxWidth: 360, borderBottom: '2px solid rgba(153,104,46,0.7)' }} />
            <CheckCircleIcon sx={{ color: '#99682E', fontSize: 28 }} />
            <Typography variant="h4" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>RECETAS</Typography>
            <CheckCircleIcon sx={{ color: '#99682E', fontSize: 28 }} />
            <Box sx={{ flex: '1 1 30%', maxWidth: 360, borderBottom: '2px solid rgba(153,104,46,0.7)' }} />
          </Box>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', mt: 2, flexWrap: 'nowrap' }}>
            <Box sx={{ flex: '1 1 50%', minWidth: 0, display: 'flex', justifyContent: 'center' }}>
              <a href="/paises"><Box component="img" src="/img/por-pais.png" alt="" sx={{ width: '100%', maxWidth: 636, maxHeight: 265, objectFit: 'contain', display: 'block' }} /></a>
            </Box>
            <Box sx={{ flex: '1 1 50%', minWidth: 0, display: 'flex', justifyContent: 'center' }}>
              <a href="/categorias"><Box component="img" src="/img/por-tipo.png" alt="" sx={{ width: '100%', maxWidth: 636, maxHeight: 265, objectFit: 'contain', display: 'block' }} /></a>
            </Box>
          </Box>
        </Box>
      </Container>

      {/* PAÍSES */}
      <Container maxWidth="xl" sx={{ py: 4, maxWidth: '1400px' }}>
        <Box textAlign="center">
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, justifyContent: 'center' }}>
            <Box sx={{ flex: '1 1 30%', maxWidth: 360, borderBottom: '2px solid rgba(153,104,46,0.7)' }} />
            <CheckCircleIcon sx={{ color: '#99682E', fontSize: 28 }} />
            <Typography variant="h4" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>PAÍSES</Typography>
            <CheckCircleIcon sx={{ color: '#99682E', fontSize: 28 }} />
            <Box sx={{ flex: '1 1 30%', maxWidth: 360, borderBottom: '2px solid rgba(153,104,46,0.7)' }} />
          </Box>
          <Box sx={{ textAlign: 'center', mt: 2 }}>
            <PaisesPreview />
          </Box>
        </Box>
      </Container>

      {/* Divider between PAÍSES and RECETA TRENDING TOPIC */}
      <Container sx={{ py: 1 }}>
        <Box sx={{ display: 'flex', justifyContent: 'center', my: 2 }}>
          <Box sx={{ width: { xs: '90%', md: '60%' }, borderTop: '4px solid rgba(153,104,46,0.85)', borderRadius: 1 }} />
        </Box>
      </Container>

      {/* RECETA TRENDING TOPIC */}
      <Container sx={{ py: 4 }}>
        <Box sx={{ display: 'flex', gap: 3, alignItems: 'center', flexWrap: { xs: 'wrap', md: 'nowrap' } }}>
          <Box sx={{ flex: '1 1 50%' }}>
            <Typography variant="h5" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700, color: '#99682E' }}>Receta Trending Topic</Typography>
            {featured ? (
              <>
                <Typography variant="h6" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700 }} id="recetaDelDiaNombre">{featured.nombre}</Typography>
                <Typography sx={{ mt: 1 }} id="recetaDelDiaDescripcion">{featured.descripcionCorta || featured.descripcion || ''}</Typography>
                <Typography sx={{ mt: 2, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Ingredientes</Typography>
                <Box component="ul" sx={{ pl: 3, mt: 1 }}>
                  {(featured.ingredientes || []).map(i => (
                    <li key={i.idIngrediente || i.id}>{i.nombre}</li>
                  ))}
                </Box>
                <Typography sx={{ mt: 2, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Preparación</Typography>
                <Typography sx={{ mt: 1, whiteSpace: 'pre-wrap' }}>{featured.preparacion || featured.descripcion || ''}</Typography>
              </>
            ) : (
              <Typography>Loading...</Typography>
            )}
          </Box>
          <Box sx={{ flex: '1 1 50%', textAlign: 'center' }}>
            {featured ? (
              <Box component="img" src={featured.urlImagen || 'https://placehold.co/624x352?text=No+Image'} alt={featured.nombre} sx={{ width: '100%', maxWidth: 624 }} id="recetaDelDiaImg" onError={(e)=>{ e.target.src='https://placehold.co/624x352?text=No+Image'; }} />
            ) : (
              <Box component="img" src="https://placehold.co/624x352?text=No+Image" alt="placeholder" sx={{ width: '100%', maxWidth: 624 }} />
            )}
          </Box>
        </Box>
      </Container>
    </Box>
  );
}

function PaisesPreview(){
  const [paises, setPaises] = useState([]);

  useEffect(()=>{
    getPaises().then(r=> setPaises(Array.isArray(r.data)? r.data.slice(0,8) : [])).catch(()=>{});
  },[]);

  return (
    <>
      {paises.map(p=> (
        <Box key={p.idPais} sx={{ textAlign: 'center', p: 1, boxSizing: 'border-box', width: { xs: '50%', sm: '50%', md: '25%' }, display: 'inline-block' }}>
          <RouterLink to={`/paises/${p.idPais}`} style={{ textDecoration: 'none', color: 'inherit' }}>
            {p.urlImagen ? (
              <Box component="img" src={p.urlImagen} alt={p.nombre} sx={{ width: '100%', height: 120, objectFit: 'cover', borderRadius: 1 }} />
            ) : (
              <Box sx={{ width: '100%', height: 120, backgroundColor: '#eee', display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: 1 }}>
                <Box component="img" src="https://placehold.co/300x200?text=No+Image" alt="placeholder" sx={{ maxWidth: '100%', maxHeight: '100%' }} />
              </Box>
            )}
            <Typography sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700, mt: 1 }}>{p.nombre}</Typography>
          </RouterLink>
        </Box>
      ))}
    </>
  );
}
