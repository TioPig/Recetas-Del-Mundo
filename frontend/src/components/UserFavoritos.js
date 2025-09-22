import React, { useEffect, useState } from 'react';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import ThumbUpIcon from '@mui/icons-material/ThumbUp';
import StarIcon from '@mui/icons-material/Star';
import { getFavoritos, getRecetas, isAuthenticated, postFavoritoReceta, postLikeReceta, postStarReceta } from '../api';
import AuthPromptDialog from './AuthPromptDialog';

export default function UserFavoritos(){
  const [favoritos, setFavoritos] = useState([]);
  const [recetas, setRecetas] = useState([]);
  const [loading, setLoading] = useState(true);
  const [authPromptOpen, setAuthPromptOpen] = useState(false);

  useEffect(()=>{
    setLoading(true);
    getFavoritos().then(r=>{
      const data = r && r.data ? r.data : r;
      setFavoritos(Array.isArray(data) ? data : (data?.favoritos || []));
    }).catch(()=> setFavoritos([])).finally(()=> setLoading(false));

    getRecetas().then(r=>{
      const data = r && r.data ? r.data : r;
      setRecetas(Array.isArray(data) ? data : (data?.recetas || data?.items || []));
    }).catch(()=> setRecetas([]));
  },[]);

  const resolved = favoritos.map(f => {
    if(!f) return null;
    if(f.idReceta || f.id) return recetas.find(r => (r.idReceta||r.id) === (f.idReceta||f.id)) || f;
    const id = typeof f === 'number' || typeof f === 'string' ? f : (f.recetaId || f.idReceta || f.id);
    return recetas.find(r => (r.idReceta||r.id).toString() === String(id)) || { idReceta: id, nombre: 'Receta', urlImagen: '' };
  }).filter(Boolean);

  return (
    <Box>
      <Box className="hero-categorias" sx={{ backgroundColor: '#F6F0E0', py: 4 }}>
        <Container>
          <Box textAlign="center">
            <Typography variant="h2" sx={{ color: '#6b4f34', fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Tus Favoritos</Typography>
          </Box>
        </Container>
      </Box>

      <Container maxWidth="xl" sx={{ py: 4, px: 2, maxWidth: '1400px', mx: 'auto' }}>
      {loading && <Typography> Cargando... </Typography>}
      <Grid container spacing={2}>
        {resolved.length === 0 && !loading && <Grid item xs={12}><Typography>No tienes favoritos aún.</Typography></Grid>}
        {resolved.map(r => (
          <Grid item key={r.idReceta || r.id} xs={12} sm={6} md={3}>
            <Box sx={{ border: '1px solid #eee', p: 2, borderRadius: 1, height: '100%', display: 'flex', flexDirection: 'column', boxSizing: 'border-box' }}>
              <Box component="img" src={r.urlImagen || 'https://placehold.co/600x360'} alt={r.nombre} onError={(e)=>{ e.target.src='https://placehold.co/600x360'; }} sx={{ width: '100%', height: 120, maxHeight: 140, objectFit: 'cover', borderRadius: 1 }} />
              <Typography sx={{ mt: 1, fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>{r.nombre}</Typography>
              <Typography color="text.secondary" sx={{ mt: 1, flexGrow: 1, fontSize: '0.95rem' }}>{r.preparacion ? (r.preparacion.length>100? r.preparacion.slice(0,100)+'...': r.preparacion) : ''}</Typography>
              <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Box>
                  <IconButton size="small" onClick={async ()=>{ if(!isAuthenticated()){ setAuthPromptOpen(true); return; } try{ await postLikeReceta(r.idReceta||r.id); }catch(e){} }} aria-label="like"><ThumbUpIcon fontSize="small" /></IconButton>
                  <IconButton size="small" onClick={async ()=>{ if(!isAuthenticated()){ setAuthPromptOpen(true); return; } try{ await postStarReceta(r.idReceta||r.id); }catch(e){} }} aria-label="star"><StarIcon fontSize="small" /></IconButton>
                  <IconButton size="small" onClick={async ()=>{ if(!isAuthenticated()){ setAuthPromptOpen(true); return; } try{ await postFavoritoReceta(r.idReceta||r.id); }catch(e){} }} aria-label="fav"><BookmarkIcon fontSize="small" /></IconButton>
                </Box>
                <Button size="small" sx={{ fontFamily: 'Open Sans, sans-serif' }}>Ver receta</Button>
              </Box>
            </Box>
          </Grid>
        ))}
      </Grid>
      <AuthPromptDialog open={authPromptOpen} onClose={()=> setAuthPromptOpen(false)} />
    </Container>
  </Box>
  );
}
