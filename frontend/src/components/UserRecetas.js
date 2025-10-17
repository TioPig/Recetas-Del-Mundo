import React, { useEffect, useState } from 'react';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import ThumbUpIcon from '@mui/icons-material/ThumbUp';
import StarIcon from '@mui/icons-material/Star';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import { getRecetas, isAuthenticated, postLikeReceta, postStarReceta, postFavoritoReceta } from '../api';
import AuthPromptDialog from './AuthPromptDialog';

export default function UserRecetas(){
  const [recetas, setRecetas] = useState([]);
  const [mine, setMine] = useState([]);
  const [loading, setLoading] = useState(true);
  const [authPromptOpen, setAuthPromptOpen] = useState(false);

  useEffect(()=>{
    setLoading(true);
    getRecetas().then(r=>{
      const data = r && r.data ? r.data : r;
      const list = Array.isArray(data) ? data : (data?.recetas || data?.items || []);
      setRecetas(list);
      let uid = null;
      try{ const u = JSON.parse(localStorage.getItem('user') || 'null'); uid = u && (u.id || u._id || u.idUsuario || u.idUsuario) }catch(e){}
      const mineList = list.filter(item => {
        if(!uid) return false;
        return (item.autorId && String(item.autorId) === String(uid)) || (item.idUsuario && String(item.idUsuario) === String(uid)) || (item.createdBy && String(item.createdBy) === String(uid));
      });
      setMine(mineList);
    }).catch(()=>{ setRecetas([]); setMine([]); }).finally(()=> setLoading(false));
  },[]);

  return (
    <Box>
      <Box className="hero-categorias" sx={{ backgroundColor: '#F6F0E0', py: 4 }}>
        <Container>
          <Box textAlign="center">
            <Typography variant="h2" sx={{ color: '#6b4f34', fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Tus Recetas</Typography>
          </Box>
        </Container>
      </Box>

      <Container maxWidth="xl" sx={{ py: 4, px: 2, maxWidth: '1400px', mx: 'auto' }}>
      {loading && <Typography>Cargando...</Typography>}
      <Grid container spacing={2}>
        {(!mine || mine.length === 0) && !loading && <Grid item xs={12}><Typography>No has creado recetas todavía.</Typography></Grid>}
        {mine.map(r => (
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
