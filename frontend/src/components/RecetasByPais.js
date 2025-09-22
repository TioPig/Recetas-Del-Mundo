import React from 'react';
import { useParams } from 'react-router-dom';
import { useEffect, useState } from 'react';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Grid from '@mui/material/Grid';
import Button from '@mui/material/Button';
import Pagination from '@mui/material/Pagination';
import TextField from '@mui/material/TextField';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import IconButton from '@mui/material/IconButton';
import Divider from '@mui/material/Divider';
import Stack from '@mui/material/Stack';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import StarIcon from '@mui/icons-material/Star';
import ThumbUpIcon from '@mui/icons-material/ThumbUp';
import { getRecetasByPais, getPais, postLikeReceta, postStarReceta, postFavoritoReceta, getComentariosReceta, postComentarioReceta, isAuthenticated } from '../api';
import AuthPromptDialog from './AuthPromptDialog';

export default function RecetasByPais(){
  const { id } = useParams();
  const [recetas, setRecetas] = useState([]);
  const [pais, setPais] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(()=>{
    setLoading(true);
    Promise.all([getRecetasByPais(id), getPais(id)])
      .then(([rRecetas, rPais])=>{
        // API may return array directly or an object with .recetas / .items
        const data = rRecetas && rRecetas.data ? rRecetas.data : rRecetas;
        const list = Array.isArray(data) ? data : (Array.isArray(data?.recetas) ? data.recetas : (Array.isArray(data?.items) ? data.items : []));
        setRecetas(list);
        setPais(rPais && rPais.data ? rPais.data : null);
        setError(null);
      })
      .catch(err=>{
        setError('Error cargando recetas o país');
        setRecetas([]);
        setPais(null);
      })
      .finally(()=> setLoading(false));
  },[id]);

  const shortText = (text, n=140) => text ? (text.length>n? text.slice(0,n).trim()+'...': text) : '';

  const [openReceta, setOpenReceta] = useState(false);
  const [selectedReceta, setSelectedReceta] = useState(null);
  const [authPromptOpen, setAuthPromptOpen] = useState(false);
  const [comentarios, setComentarios] = useState([]);
  const [newComentario, setNewComentario] = useState('');
  const loadComentarios = async (recetaId) => {
    if(!recetaId) return setComentarios([]);
    try{
      const r = await getComentariosReceta(recetaId);
      const data = r && r.data ? r.data : r;
      const list = Array.isArray(data) ? data : (Array.isArray(data?.comentarios) ? data.comentarios : (Array.isArray(data?.items) ? data.items : []));
      setComentarios(list);
    }catch(e){ setComentarios([]); }
  };
  const [page, setPage] = useState(1);
  const rows = 10; // user requested 10 filas
  const [search, setSearch] = useState('');
  const theme = useTheme();
  const isMd = useMediaQuery(theme.breakpoints.up('md'));
  const isSm = useMediaQuery(theme.breakpoints.up('sm'));
  const columns = isMd ? 4 : (isSm ? 2 : 1);
  const perPage = rows * columns;

  useEffect(()=>{
    setPage(1);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  },[columns]);

  // filtered recetas by search
  const filteredRecetas = recetas.filter(r => {
    if(!search || !search.trim()) return true;
    const s = search.trim().toLowerCase();
    return (r.nombre || '').toString().toLowerCase().includes(s);
  });

  const handleOpenReceta = (receta) => {
    setSelectedReceta(receta);
    // load comments for this receta
    loadComentarios(receta?.idReceta || receta?.id);
    setOpenReceta(true);
  };
  const handleCloseReceta = () => { setOpenReceta(false); setSelectedReceta(null); };

  return (
    <Box>
      {/* Hero similar to original */}
      <Box className="hero-categorias" sx={{ backgroundColor: '#F6F0E0', py: 4 }}>
        <Container>
          <Box textAlign="center">
            <Typography variant="h2" sx={{ color: '#6b4f34', fontFamily: 'Lato, sans-serif', fontWeight: 700 }} id="nombrePais">
              {pais ? pais.nombre : 'País'}
            </Typography>
          </Box>
        </Container>
      </Box>

  <Container maxWidth="xl" sx={{ py: 4, px: 2, maxWidth: '1400px', mx: 'auto' }}>
        {loading && <Typography>Loading...</Typography>}
        {error && <Typography color="error">{error}</Typography>}
        <Box sx={{ mb: 2, display: 'flex', justifyContent: 'center' }}>
          <TextField size="small" placeholder="Buscar en estas recetas..." value={search} onChange={(e)=>{ setSearch(e.target.value); setPage(1); }} sx={{ minWidth: 300 }} />
        </Box>

        <Grid container spacing={2} id="recetas" justifyContent="center">
          {recetas.length === 0 && !loading && <Grid item xs={12}><Typography>No se encontraron recetas para este país.</Typography></Grid>}
          {filteredRecetas.slice((page-1)*perPage, page*perPage).map(r => (
            <Grid item key={r.idReceta || r.id} sx={{ width: { xs: '100%', sm: '48%', md: '23%' } }}> 
              <Box sx={{ border: '1px solid #eee', p: 2, borderRadius: 1, height: '100%', display: 'flex', flexDirection: 'column', boxSizing: 'border-box', width: '100%' }}>
                <Box component="img" src={r.urlImagen || 'https://placehold.co/600x360'} alt={r.nombre} onError={(e)=>{ e.target.src='https://placehold.co/600x360'; }} sx={{ width: '100%', height: 120, maxHeight: 140, objectFit: 'cover', borderRadius: 1 }} />
                <Typography sx={{ mt: 1, fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>{r.nombre}</Typography>
                <Typography color="text.secondary" sx={{ mt: 1, flexGrow: 1 }}>{shortText(r.preparacion, 100)}</Typography>
                <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <Typography variant="caption" color="text.secondary">{r.fechaCreacion}</Typography>
                  <Box>
                    <IconButton size="small" onClick={async ()=>{ if(!isAuthenticated()){ setAuthPromptOpen(true); return; } try{ await postLikeReceta(r.idReceta || r.id); }catch(e){} }} aria-label="like"><ThumbUpIcon fontSize="small" /></IconButton>
                    <IconButton size="small" onClick={async ()=>{ if(!isAuthenticated()){ setAuthPromptOpen(true); return; } try{ await postStarReceta(r.idReceta || r.id); }catch(e){} }} aria-label="star"><StarIcon fontSize="small" /></IconButton>
                    <IconButton size="small" onClick={async ()=>{ if(!isAuthenticated()){ setAuthPromptOpen(true); return; } try{ await postFavoritoReceta(r.idReceta || r.id); }catch(e){} }} aria-label="fav"><BookmarkIcon fontSize="small" /></IconButton>
                    <Button onClick={() => handleOpenReceta(r)} size="small" sx={{ fontFamily: 'Open Sans, sans-serif' }}>Ver receta</Button>
                  </Box>
                </Box>
              </Box>
            </Grid>
          ))}
        </Grid>

        {filteredRecetas.length > perPage && (
          <Box sx={{ display: 'flex', justifyContent: 'center', mt: 3 }}>
            <Pagination count={Math.ceil(filteredRecetas.length / perPage)} page={page} onChange={(e, value) => setPage(value)} color="primary" />
          </Box>
        )}

        <Dialog open={openReceta} onClose={handleCloseReceta} fullWidth maxWidth="md">
            <DialogTitle sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>{selectedReceta?.nombre}</DialogTitle>
          <DialogContent dividers>
            <Box component="img" src={selectedReceta?.urlImagen || 'https://placehold.co/800x480'} alt={selectedReceta?.nombre} onError={(e)=>{ e.target.src='https://placehold.co/800x480'; }} sx={{ width: '100%', height: 360, maxHeight: 480, objectFit: 'cover', borderRadius: 1 }} />
            {/* moved action buttons to after preparación */}
            <Typography sx={{ mt: 2, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Ingredientes</Typography>
            <Box component="ul" sx={{ pl: 2, mt: 1, mb: 2 }}>
                {(selectedReceta?.ingredientes || []).map(i => (
                <Box component="li" key={i.idIngrediente} sx={{ listStyleType: 'disc', ml: 1, fontSize: '0.95rem' }}>{i.nombre}</Box>
              ))}
            </Box>
            <Typography sx={{ mt: 2, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Preparación</Typography>
            <Typography sx={{ whiteSpace: 'pre-wrap' }}>{selectedReceta?.preparacion}</Typography>
            <Divider sx={{ my: 2 }} />
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <IconButton aria-label="like" onClick={async ()=>{ if(!isAuthenticated()){ setAuthPromptOpen(true); return; } try{ await postLikeReceta(selectedReceta?.idReceta || selectedReceta?.id); }catch(e){} }}><ThumbUpIcon /></IconButton>
              <IconButton aria-label="star" onClick={async ()=>{ if(!isAuthenticated()){ setAuthPromptOpen(true); return; } try{ await postStarReceta(selectedReceta?.idReceta || selectedReceta?.id); }catch(e){} }}><StarIcon /></IconButton>
              <IconButton aria-label="fav" onClick={async ()=>{ if(!isAuthenticated()){ setAuthPromptOpen(true); return; } try{ await postFavoritoReceta(selectedReceta?.idReceta || selectedReceta?.id); }catch(e){} }}><BookmarkIcon /></IconButton>
              <Box sx={{ ml: 2, color: 'text.secondary' }}>
                <span>{selectedReceta?.likes || selectedReceta?.likesCount || 0} Me gusta</span>
                <span style={{ marginLeft: 12 }}>{selectedReceta?.stars || selectedReceta?.starsCount || 0} Estrellas</span>
              </Box>
            </Box>
            <Typography sx={{ fontWeight: 700, mt: 2 }}>Comentarios</Typography>
            <List>
              {(comentarios || []).map(c => (
                <ListItem key={c.idComentario || c.id}><ListItemText primary={c.autor || c.nombre || 'Anon'} secondary={c.texto || c.comentario} /></ListItem>
              ))}
            </List>
            <Box sx={{ display: 'flex', gap: 1, mt: 1 }}>
              <TextField size="small" fullWidth placeholder="Escribe un comentario..." value={newComentario} onChange={(e)=> setNewComentario(e.target.value)} />
              <Button size="small" variant="contained" onClick={async ()=>{ if(!isAuthenticated()){ setAuthPromptOpen(true); return; } if(!newComentario || !newComentario.trim()) return; try{ await postComentarioReceta(selectedReceta?.idReceta || selectedReceta?.id, { texto: newComentario }); setNewComentario(''); await loadComentarios(selectedReceta?.idReceta || selectedReceta?.id); }catch(e){} }}>Enviar</Button>
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseReceta}>Cerrar</Button>
          </DialogActions>
        </Dialog>
        <AuthPromptDialog open={authPromptOpen} onClose={()=> setAuthPromptOpen(false)} />
      </Container>

      {/* small footer-like section "Países" heading to mirror original layout */}
  <Container maxWidth="xl" sx={{ py: 2, maxWidth: '1400px' }}>
        <Box textAlign="center">
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 2 }}>
            <Box sx={{ width: '40%', height: 1, backgroundColor: '#ddd' }} />
            <Typography sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 900, color: '#6b4f34' }}>Países</Typography>
            <Box sx={{ width: '40%', height: 1, backgroundColor: '#ddd' }} />
          </Box>
        </Box>
      </Container>
    </Box>
  );
}
