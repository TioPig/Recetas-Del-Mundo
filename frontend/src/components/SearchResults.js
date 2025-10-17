import React from 'react';
import { useSearchParams } from 'react-router-dom';
import { useEffect, useState } from 'react';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Grid from '@mui/material/Grid';
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import Pagination from '@mui/material/Pagination';
import TextField from '@mui/material/TextField';
import IconButton from '@mui/material/IconButton';
import Divider from '@mui/material/Divider';
import Stack from '@mui/material/Stack';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import BookmarkBorderIcon from '@mui/icons-material/BookmarkBorder';
import StarIcon from '@mui/icons-material/Star';
import StarBorderIcon from '@mui/icons-material/StarBorder';
import ThumbUpIcon from '@mui/icons-material/ThumbUp';
import ThumbUpOutlinedIcon from '@mui/icons-material/ThumbUpOutlined';
import { searchRecetasByNombre, postLikeReceta, deleteLikeReceta, postStarReceta, postFavoritoReceta, deleteFavoritoReceta, getComentariosReceta, postComentarioReceta, isAuthenticated, getMeGustaCount, getEstrellaStats, getMeGustas, getEstrellas, getFavoritos } from '../api';
import AuthPromptDialog from './AuthPromptDialog';
import RatingDialog from './RatingDialog';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';

export default function SearchResults(){
  const [searchParams] = useSearchParams();
  const q = searchParams.get('q') || '';
  const [recetas, setRecetas] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(()=>{
    if(!q || !q.trim()){
      setRecetas([]); return;
    }
    setLoading(true);
    searchRecetasByNombre(q)
      .then(r=>{
        const data = r && r.data ? r.data : r;
        const list = Array.isArray(data) ? data : (Array.isArray(data?.recetas) ? data.recetas : (Array.isArray(data?.items) ? data.items : []));
        setRecetas(list);
        setError(null);
      })
      .catch(e=>{
        setError('Error buscando recetas');
        setRecetas([]);
      })
      .finally(()=> setLoading(false));
  },[q]);

  // pagination by rows
  const [page, setPage] = useState(1);
  const rows = 10;
  const theme = useTheme();
  const isMd = useMediaQuery(theme.breakpoints.up('md'));
  const isSm = useMediaQuery(theme.breakpoints.up('sm'));
  const columns = isMd ? 4 : (isSm ? 2 : 1);
  const perPage = rows * columns;

  useEffect(()=>{ setPage(1); },[columns, q]);

  const shortText = (text, n=140) => text ? (text.length>n? text.slice(0,n).trim()+'...': text) : '';

  const [openReceta, setOpenReceta] = useState(false);
  const [selectedReceta, setSelectedReceta] = useState(null);
  const [comentarios, setComentarios] = useState([]);
  const [newComentario, setNewComentario] = useState('');
  const [authPromptOpen, setAuthPromptOpen] = useState(false);
  const [userInteractions, setUserInteractions] = useState({ likes: new Set(), favoritos: new Set(), estrellas: new Map() });
  const [modalStats, setModalStats] = useState({ likesCount: 0, avgStars: 0, totalStars: 0 });

  // Cargar interacciones del usuario al montar
  useEffect(() => {
    if(isAuthenticated()) {
      // Obtener ID del usuario actual
      const user = JSON.parse(localStorage.getItem('user') || '{}');
      const currentUserId = user.id_usr || user.idUsr || user.id;

      Promise.all([
        getFavoritos().catch(() => ({ data: [] })),
        getMeGustas().catch(() => ({ data: [] })),
        getEstrellas().catch(() => ({ data: [] }))
      ]).then(([favoritosRes, likesRes, estrellasRes]) => {
        const favoritosData = Array.isArray(favoritosRes?.data) ? favoritosRes.data : [];
        const likesData = Array.isArray(likesRes?.data) ? likesRes.data : [];
        const estrellasData = Array.isArray(estrellasRes?.data) ? estrellasRes.data : [];

        const newLikes = new Set();
        const newFavoritos = new Set();
        const newEstrellas = new Map();

        favoritosData.forEach(fav => {
          // Filtrar solo favoritos del usuario actual
          const userId = fav.usuario?.idUsr || fav.usuario?.id || fav.idUsuario || fav.idUsr;
          if(currentUserId && userId && userId === currentUserId) {
            const recetaId = fav.idReceta || fav.id_receta || fav.receta?.idReceta || fav.receta?.id;
            if(recetaId) newFavoritos.add(recetaId);
          }
        });

        likesData.forEach(like => {
          // Filtrar solo likes del usuario actual
          const userId = like.usuario?.idUsr || like.usuario?.id || like.idUsuario || like.idUsr;
          if(currentUserId && userId && userId === currentUserId) {
            const recetaId = like.idReceta || like.id_receta || like.receta?.idReceta || like.receta?.id;
            if(recetaId) newLikes.add(recetaId);
          }
        });

        estrellasData.forEach(estrella => {
          // Filtrar solo estrellas del usuario actual
          const userId = estrella.usuario?.idUsr || estrella.usuario?.id || estrella.idUsuario || estrella.idUsr;
          if(currentUserId && userId && userId === currentUserId) {
            const recetaId = estrella.idReceta || estrella.id_receta || estrella.receta?.idReceta || estrella.receta?.id;
            const valor = estrella.estrellas || estrella.valorEstrellas || estrella.valor || 0;
            if(recetaId) newEstrellas.set(recetaId, valor);
          }
        });

        setUserInteractions({ likes: newLikes, favoritos: newFavoritos, estrellas: newEstrellas });
      });
    }
  }, []);

  const loadComentarios = async (recetaId) => {
    if(!recetaId) return setComentarios([]);
    try{
      const r = await getComentariosReceta(recetaId);
      const data = r && r.data ? r.data : r;
      const list = Array.isArray(data) ? data : (Array.isArray(data?.comentarios) ? data.comentarios : (Array.isArray(data?.items) ? data.items : []));
      setComentarios(list);
    }catch(e){ setComentarios([]); }
  };

  const loadModalStats = async (recetaId) => {
    if(!recetaId) return;
    try {
      const [likesRes, starsRes] = await Promise.all([
        getMeGustaCount(recetaId).catch(() => ({ data: { count: 0 } })),
        getEstrellaStats(recetaId).catch(() => ({ data: { promedio: 0, total: 0 } }))
      ]);
      
      const likesData = likesRes?.data || likesRes;
      const starsData = starsRes?.data || starsRes;
      
      setModalStats({
        likesCount: likesData?.count || likesData?.total || 0,
        avgStars: starsData?.promedio || starsData?.average || starsData?.avg || 0,
        totalStars: starsData?.total || starsData?.count || 0
      });
    } catch(e) {
      // Error silencioso
    }
  };

  const handleLike = async (recetaId) => {
    if(!isAuthenticated()){ setAuthPromptOpen(true); return; }
    try{
      const isLiked = userInteractions.likes.has(recetaId);
      if(isLiked){
        await deleteLikeReceta(recetaId);
        setUserInteractions(prev => {
          const newLikes = new Set(prev.likes);
          newLikes.delete(recetaId);
          return { ...prev, likes: newLikes };
        });
      }else{
        await postLikeReceta(recetaId);
        setUserInteractions(prev => {
          const newLikes = new Set(prev.likes);
          newLikes.add(recetaId);
          return { ...prev, likes: newLikes };
        });
      }
      if(openReceta && (selectedReceta?.idReceta === recetaId || selectedReceta?.id === recetaId)) {
        loadModalStats(recetaId);
      }
    }catch(e){}
  };

  const handleFavorito = async (recetaId) => {
    if(!isAuthenticated()){ setAuthPromptOpen(true); return; }
    try{
      const isFavorito = userInteractions.favoritos.has(recetaId);
      if(isFavorito){
        await deleteFavoritoReceta(recetaId);
        setUserInteractions(prev => {
          const newFavoritos = new Set(prev.favoritos);
          newFavoritos.delete(recetaId);
          return { ...prev, favoritos: newFavoritos };
        });
      }else{
        await postFavoritoReceta(recetaId);
        setUserInteractions(prev => {
          const newFavoritos = new Set(prev.favoritos);
          newFavoritos.add(recetaId);
          return { ...prev, favoritos: newFavoritos };
        });
      }
    }catch(e){}
  };

  const handleStar = async (recetaId) => {
    if(!isAuthenticated()){ setAuthPromptOpen(true); return; }
    try{
      await postStarReceta(recetaId);
      setUserInteractions(prev => {
        const newEstrellas = new Map(prev.estrellas);
        newEstrellas.set(recetaId, 5);
        return { ...prev, estrellas: newEstrellas };
      });
      if(openReceta && (selectedReceta?.idReceta === recetaId || selectedReceta?.id === recetaId)) {
        loadModalStats(recetaId);
      }
    }catch(e){}
  };

  const handleOpenReceta = async (receta) => { 
    setSelectedReceta(receta); 
    const recetaId = receta?.idReceta || receta?.id;
    Promise.all([
      loadComentarios(recetaId),
      loadModalStats(recetaId)
    ]);
    setOpenReceta(true); 
  };
  
  const handleCloseReceta = () => { 
    setOpenReceta(false); 
    setSelectedReceta(null); 
    setModalStats({ likesCount: 0, avgStars: 0, totalStars: 0 });
  };

  return (
    <Box>
      <Box sx={{ backgroundColor: '#F6F0E0', py: 4 }}>
        <Container>
          <Box textAlign="center">
            <Typography variant="h2" sx={{ color: '#6b4f34', fontFamily: 'Lato, sans-serif', fontWeight: 700 }} id="nombreBusqueda">
              Resultados de búsqueda: "{q}"
            </Typography>
          </Box>
        </Container>
      </Box>
  <Container maxWidth="xl" sx={{ py: 4, px: 2, maxWidth: '1400px', mx: 'auto' }}>
        {loading && <Typography>Buscando...</Typography>}
        {error && <Typography color="error">{error}</Typography>}

        <Box sx={{ mb: 2, display: 'flex', justifyContent: 'center' }}>
          <TextField size="small" value={q} disabled sx={{ minWidth: 300 }} />
        </Box>

        <Grid container spacing={2} justifyContent="center">
          {recetas.length === 0 && !loading && <Grid item xs={12}><Typography>No se encontraron recetas.</Typography></Grid>}
          {recetas.slice((page-1)*perPage, page*perPage).map(r => (
            <Grid item key={r.idReceta || r.id} sx={{ width: { xs: '100%', sm: '48%', md: '23%' } }}>
              <Box sx={{ border: '1px solid #eee', p: 2, borderRadius: 1, height: '100%', display: 'flex', flexDirection: 'column' }}>
                <Box component="img" src={r.urlImagen || 'https://placehold.co/600x360'} alt={r.nombre} onError={(e)=>{ e.target.src='https://placehold.co/600x360'; }} sx={{ width: '100%', height: 120, maxHeight: 140, objectFit: 'cover', borderRadius: 1 }} />
                <Typography sx={{ mt: 1, fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>{r.nombre}</Typography>
                <Typography color="text.secondary" sx={{ mt: 1, flexGrow: 1 }}>{shortText(r.preparacion, 100)}</Typography>
                <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <Typography variant="caption" color="text.secondary">{r.fechaCreacion}</Typography>
                  <Box>
                    <IconButton size="small" onClick={() => handleLike(r.idReceta || r.id)} aria-label="like">
                      {userInteractions.likes.has(r.idReceta || r.id) ? <ThumbUpIcon fontSize="small" color="primary" /> : <ThumbUpOutlinedIcon fontSize="small" />}
                    </IconButton>
                    <IconButton size="small" onClick={() => handleStar(r.idReceta || r.id)} aria-label="star">
                      {userInteractions.estrellas.has(r.idReceta || r.id) ? <StarIcon fontSize="small" color="warning" /> : <StarBorderIcon fontSize="small" />}
                    </IconButton>
                    <IconButton size="small" onClick={() => handleFavorito(r.idReceta || r.id)} aria-label="fav">
                      {userInteractions.favoritos.has(r.idReceta || r.id) ? <BookmarkIcon fontSize="small" color="error" /> : <BookmarkBorderIcon fontSize="small" />}
                    </IconButton>
                    <Button onClick={() => handleOpenReceta(r)} size="small">Ver receta</Button>
                  </Box>
                </Box>
              </Box>
            </Grid>
          ))}
        </Grid>

        {recetas.length > perPage && (
          <Box sx={{ display: 'flex', justifyContent: 'center', mt: 3 }}>
            <Pagination count={Math.ceil(recetas.length / perPage)} page={page} onChange={(e, value) => setPage(value)} color="primary" />
          </Box>
        )}

        <Dialog open={openReceta} onClose={handleCloseReceta} fullWidth maxWidth="md">
            <DialogTitle>{selectedReceta?.nombre}</DialogTitle>
          <DialogContent dividers>
            <Box component="img" src={selectedReceta?.urlImagen || 'https://placehold.co/800x480'} alt={selectedReceta?.nombre} onError={(e)=>{ e.target.src='https://placehold.co/800x480'; }} sx={{ width: '100%', height: 360, maxHeight: 480, objectFit: 'cover', borderRadius: 1 }} />
            <Typography sx={{ mt: 2, fontWeight: 700 }}>Ingredientes</Typography>
              <Box component="ul" sx={{ pl: 2, mt: 1, mb: 2 }}>
                {(selectedReceta?.ingredientes || []).map(i => (
                  <Box component="li" key={i.idIngrediente} sx={{ listStyleType: 'disc', ml: 1, fontSize: '0.95rem' }}>{i.nombre}</Box>
                ))}
              </Box>
            <Typography sx={{ mt: 2, fontWeight: 700 }}>Preparación</Typography>
            <Typography sx={{ whiteSpace: 'pre-wrap' }}>{selectedReceta?.preparacion}</Typography>
            <Divider sx={{ my: 2 }} />
            
            {/* Botones de interacción con estadísticas */}
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 2 }}>
              {/* Botones e interacciones de izquierda */}
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                {/* Botón Me Gusta con contador */}
                <IconButton aria-label="like" onClick={() => handleLike(selectedReceta?.idReceta || selectedReceta?.id)}>
                  {userInteractions.likes.has(selectedReceta?.idReceta || selectedReceta?.id) ? <ThumbUpIcon color="primary" /> : <ThumbUpOutlinedIcon />}
                </IconButton>
                <Typography variant="body2" sx={{ fontWeight: 600, mr: 2 }}>
                  {modalStats.likesCount}
                </Typography>
                
                {/* Botón Estrellas con promedio */}
                <IconButton aria-label="star" onClick={() => handleStar(selectedReceta?.idReceta || selectedReceta?.id)}>
                  {userInteractions.estrellas.has(selectedReceta?.idReceta || selectedReceta?.id) ? <StarIcon color="warning" /> : <StarBorderIcon />}
                </IconButton>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>
                  {modalStats.avgStars > 0 ? modalStats.avgStars.toFixed(1) : '0.0'}
                  <Typography component="span" variant="body2" sx={{ ml: 0.5, color: 'text.secondary', fontWeight: 400 }}>
                    ({modalStats.totalStars})
                  </Typography>
                </Typography>
              </Box>
              
              {/* Botón Favorito a la derecha */}
              <IconButton aria-label="fav" onClick={() => handleFavorito(selectedReceta?.idReceta || selectedReceta?.id)}>
                {userInteractions.favoritos.has(selectedReceta?.idReceta || selectedReceta?.id) ? <BookmarkIcon color="error" /> : <BookmarkBorderIcon />}
              </IconButton>
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
    </Box>
  );
}
