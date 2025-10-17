import React from 'react';
import { useParams } from 'react-router-dom';
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
import IconButton from '@mui/material/IconButton';
import Divider from '@mui/material/Divider';
import Stack from '@mui/material/Stack';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import BookmarkBorderIcon from '@mui/icons-material/BookmarkBorder';
import StarIcon from '@mui/icons-material/Star';
import StarBorderIcon from '@mui/icons-material/StarBorder';
import ThumbUpIcon from '@mui/icons-material/ThumbUp';
import ThumbUpOutlinedIcon from '@mui/icons-material/ThumbUpOutlined';
import TextField from '@mui/material/TextField';
import { getRecetasByCategoria, getCategoria, postLikeReceta, deleteLikeReceta, postStarReceta, postFavoritoReceta, deleteFavoritoReceta, getComentariosReceta, postComentarioReceta, isAuthenticated, getEstrellaStats, getMeGustaCount, getFavoritos, getMeGustas, getEstrellas } from '../api';
import AuthPromptDialog from './AuthPromptDialog';
import RatingDialog from './RatingDialog';
import Pagination from '@mui/material/Pagination';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';

export default function RecetasByCategoria(){
  const { id } = useParams();
  const [recetas, setRecetas] = useState([]);
  const [cat, setCat] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(()=>{
    setLoading(true);
    Promise.all([getRecetasByCategoria(id), getCategoria(id)])
      .then(([rRecetas, rCat])=>{
        const data = rRecetas && rRecetas.data ? rRecetas.data : rRecetas;
        const list = Array.isArray(data) ? data : (Array.isArray(data?.recetas) ? data.recetas : (Array.isArray(data?.items) ? data.items : []));
        setRecetas(list);
        setCat(rCat && rCat.data ? rCat.data : null);
        setError(null);
        
        // Cargar estadísticas de cada receta
        loadRecetaStats(list);
        
        // Cargar interacciones del usuario si está autenticado
        if(isAuthenticated()) {
          loadUserInteractions();
        }
      })
      .catch(err=>{
        setError('Error cargando recetas o categoría');
        setRecetas([]);
        setCat(null);
      })
      .finally(()=> setLoading(false));
  },[id]);

  // Función para cargar estadísticas de recetas (me gustas y estrellas) - CARGA SECUENCIAL
  const loadRecetaStats = async (recetasList) => {
    if (!recetasList || recetasList.length === 0) {
      console.log('📊 No hay recetas para cargar estadísticas');
      return;
    }

    console.log(`📊 Cargando estadísticas para ${recetasList.length} recetas de forma secuencial...`);
    
    const stats = {};
    
    // Usar for loop para carga secuencial (una por una)
    for (const receta of recetasList) {
      const recetaId = receta.idReceta || receta.id;
      
      try {
        console.log(`🔄 Cargando estadísticas de receta ${recetaId}...`);
        
        // Cargar likes
        let likesCount = 0;
        try {
          const likesRes = await getMeGustaCount(recetaId);
          likesCount = likesRes?.data?.count || 0;
          console.log(`  👍 Likes: ${likesCount}`);
        } catch (err) {
          console.warn(`  ⚠️ Error cargando likes para receta ${recetaId}:`, err.message);
        }
        
        // Cargar estrellas
        let avgStars = 0;
        let totalStars = 0;
        try {
          const starsRes = await getEstrellaStats(recetaId);
          avgStars = starsRes?.data?.promedio || 0;
          totalStars = starsRes?.data?.total || 0;
          console.log(`  ⭐ Promedio: ${avgStars}, Total: ${totalStars}`);
        } catch (err) {
          console.warn(`  ⚠️ Error cargando estrellas para receta ${recetaId}:`, err.message);
        }
        
        stats[recetaId] = {
          likesCount,
          avgStars,
          totalStars
        };
        
        // Actualizar el estado después de cada receta para mostrar progreso
        setRecetaStats(prev => ({
          ...prev,
          [recetaId]: { likesCount, avgStars, totalStars }
        }));
        
      } catch (err) {
        console.error(`❌ Error procesando receta ${recetaId}:`, err);
        stats[recetaId] = { likesCount: 0, avgStars: 0, totalStars: 0 };
      }
    }
    
    console.log(`✅ Estadísticas cargadas para ${Object.keys(stats).length} recetas`);
  };

  // Función para cargar interacciones del usuario (favoritos, likes, estrellas)
  const loadUserInteractions = async () => {
    try {
      // Obtener ID del usuario actual
      const user = JSON.parse(localStorage.getItem('user') || '{}');
      const currentUserId = user.id_usr || user.idUsr || user.id;

      const [favoritosRes, likesRes, estrellasRes] = await Promise.all([
        getFavoritos().catch(() => ({ data: [] })),
        getMeGustas().catch(() => ({ data: [] })),
        getEstrellas().catch(() => ({ data: [] }))
      ]);

      const favoritosData = Array.isArray(favoritosRes?.data) ? favoritosRes.data : [];
      const likesData = Array.isArray(likesRes?.data) ? likesRes.data : [];
      const estrellasData = Array.isArray(estrellasRes?.data) ? estrellasRes.data : [];

      const newLikes = new Set();
      const newFavoritos = new Set();
      const newEstrellas = new Map();

      // Procesar favoritos - filtrar solo del usuario actual
      favoritosData.forEach(fav => {
        const userId = fav.usuario?.idUsr || fav.usuario?.id || fav.idUsuario || fav.idUsr;
        if(currentUserId && userId && userId === currentUserId) {
          const recetaId = fav.idReceta || fav.id_receta || fav.receta?.idReceta || fav.receta?.id;
          if(recetaId) newFavoritos.add(recetaId);
        }
      });

      // Procesar likes - filtrar solo del usuario actual
      likesData.forEach(like => {
        const userId = like.usuario?.idUsr || like.usuario?.id || like.idUsuario || like.idUsr;
        if(currentUserId && userId && userId === currentUserId) {
          const recetaId = like.idReceta || like.id_receta || like.receta?.idReceta || like.receta?.id;
          if(recetaId) newLikes.add(recetaId);
        }
      });

      // Procesar estrellas - filtrar solo del usuario actual
      estrellasData.forEach(estrella => {
        const userId = estrella.usuario?.idUsr || estrella.usuario?.id || estrella.idUsuario || estrella.idUsr;
        if(currentUserId && userId && userId === currentUserId) {
          const recetaId = estrella.idReceta || estrella.id_receta || estrella.receta?.idReceta || estrella.receta?.id;
          const valor = estrella.estrellas || estrella.valorEstrellas || estrella.valor || 0;
          if(recetaId) newEstrellas.set(recetaId, valor);
        }
      });

      setUserInteractions({
        likes: newLikes,
        favoritos: newFavoritos,
        estrellas: newEstrellas
      });
    } catch (err) {
      console.error('Error cargando interacciones del usuario:', err);
    }
  };

  const shortText = (text, n=140) => text ? (text.length>n? text.slice(0,n).trim()+'...': text) : '';

  const [openReceta, setOpenReceta] = useState(false);
  const [selectedReceta, setSelectedReceta] = useState(null);
  const [authPromptOpen, setAuthPromptOpen] = useState(false);
  const [ratingDialogOpen, setRatingDialogOpen] = useState(false);
  const [ratingRecetaId, setRatingRecetaId] = useState(null);
  const [ratingRecetaNombre, setRatingRecetaNombre] = useState('');
  const [userInteractions, setUserInteractions] = useState({ likes: new Set(), favoritos: new Set(), estrellas: new Map() });
  const [recetaStats, setRecetaStats] = useState({}); // { recetaId: { likesCount: N, avgStars: X, totalStars: Y } }
  const [modalStats, setModalStats] = useState({ likesCount: 0, avgStars: 0, totalStars: 0 }); // Estadísticas del modal
  const [comentarios, setComentarios] = useState([]);
  const [newComentario, setNewComentario] = useState('');
  
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
        // Actualizar contador de likes
        setRecetaStats(prev => ({
          ...prev,
          [recetaId]: { ...prev[recetaId], likesCount: Math.max(0, (prev[recetaId]?.likesCount || 0) - 1) }
        }));
      }else{
        await postLikeReceta(recetaId);
        setUserInteractions(prev => {
          const newLikes = new Set(prev.likes);
          newLikes.add(recetaId);
          return { ...prev, likes: newLikes };
        });
        // Actualizar contador de likes
        setRecetaStats(prev => ({
          ...prev,
          [recetaId]: { ...prev[recetaId], likesCount: (prev[recetaId]?.likesCount || 0) + 1 }
        }));
      }
      // Recargar estadísticas del modal si está abierto
      if(openReceta && (selectedReceta?.idReceta === recetaId || selectedReceta?.id === recetaId)) {
        loadModalStats(recetaId);
      }
    }catch(e){ 
      console.error('Error al dar like:', e);
      // Si el error es "duplicate key" (400), significa que ya existe, hacer toggle
      if(e?.response?.status === 400 && e?.response?.data?.mensaje?.includes('duplicate key')) {
        // Ya existe, entonces lo eliminamos
        try {
          await deleteLikeReceta(recetaId);
          setUserInteractions(prev => {
            const newLikes = new Set(prev.likes);
            newLikes.delete(recetaId);
            return { ...prev, likes: newLikes };
          });
          setRecetaStats(prev => ({
            ...prev,
            [recetaId]: { ...prev[recetaId], likesCount: Math.max(0, (prev[recetaId]?.likesCount || 0) - 1) }
          }));
          // Recargar estadísticas del modal
          if(openReceta && (selectedReceta?.idReceta === recetaId || selectedReceta?.id === recetaId)) {
            loadModalStats(recetaId);
          }
        } catch(deleteErr) {
          console.error('Error al eliminar like duplicado:', deleteErr);
        }
      }
    }
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
    }catch(e){ 
      console.error('Error al marcar favorito:', e);
      // Si el error es "duplicate key" (400), significa que ya existe, hacer toggle
      if(e?.response?.status === 400 && e?.response?.data?.mensaje?.includes('duplicate key')) {
        // Ya existe, entonces lo eliminamos
        try {
          await deleteFavoritoReceta(recetaId);
          setUserInteractions(prev => {
            const newFavoritos = new Set(prev.favoritos);
            newFavoritos.delete(recetaId);
            return { ...prev, favoritos: newFavoritos };
          });
        } catch(deleteErr) {
          console.error('Error al eliminar favorito duplicado:', deleteErr);
        }
      }
    }
  };

  const handleOpenRating = (recetaId, recetaNombre) => {
    if(!isAuthenticated()){ setAuthPromptOpen(true); return; }
    setRatingRecetaId(recetaId);
    setRatingRecetaNombre(recetaNombre);
    setRatingDialogOpen(true);
  };

  const handleRate = async (valorEstrellas) => {
    if(!ratingRecetaId) return;
    try{
      await postStarReceta(ratingRecetaId, valorEstrellas);
      setUserInteractions(prev => {
        const newEstrellas = new Map(prev.estrellas);
        newEstrellas.set(ratingRecetaId, valorEstrellas);
        return { ...prev, estrellas: newEstrellas };
      });
      // Actualizar estadísticas de estrellas
      const statsRes = await getEstrellaStats(ratingRecetaId);
      if(statsRes?.data) {
        setRecetaStats(prev => ({
          ...prev,
          [ratingRecetaId]: {
            ...prev[ratingRecetaId],
            avgStars: statsRes.data.promedio || 0,
            totalStars: statsRes.data.total || 0
          }
        }));
      }
      // Recargar estadísticas del modal si está abierto
      if(openReceta && (selectedReceta?.idReceta === ratingRecetaId || selectedReceta?.id === ratingRecetaId)) {
        loadModalStats(ratingRecetaId);
      }
    }catch(e){ console.error('Error al calificar:', e); }
  };
  
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
  const rows = 10;
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

  const filteredRecetas = recetas.filter(r => {
    if(!search || !search.trim()) return true;
    const s = search.trim().toLowerCase();
    return (r.nombre || '').toString().toLowerCase().includes(s);
  });

  const handleOpenReceta = async (receta) => {
    setSelectedReceta(receta);
    const recetaId = receta?.idReceta || receta?.id;
    
    // Cargar comentarios y estadísticas en paralelo
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

  return (
    <Box>
      <Box sx={{ backgroundColor: '#F6F0E0', py: 4 }}>
        <Container>
          <Box textAlign="center">
            <Typography variant="h2" sx={{ color: '#6b4f34', fontFamily: 'Lato, sans-serif', fontWeight: 700 }} id="nombreCategoria">
              {cat ? cat.nombre : 'Categoría'}
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
          {recetas.length === 0 && !loading && <Grid item xs={12}><Typography>No se encontraron recetas para esta categoría.</Typography></Grid>}
          {filteredRecetas.slice((page-1)*perPage, page*perPage).map(r => (
            <Grid item key={r.idReceta || r.id} sx={{ width: { xs: '100%', sm: '48%', md: '23%' } }}>
              <Box sx={{ border: '1px solid #eee', p: 2, borderRadius: 1, height: '100%', display: 'flex', flexDirection: 'column', boxSizing: 'border-box', width: '100%' }}>
                <Box component="img" src={r.urlImagen || 'https://placehold.co/600x360'} alt={r.nombre} onError={(e)=>{ e.target.src='https://placehold.co/600x360'; }} sx={{ width: '100%', height: 120, maxHeight: 140, objectFit: 'cover', borderRadius: 1 }} />
                <Typography sx={{ mt: 1, fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>{r.nombre}</Typography>
                <Typography color="text.secondary" sx={{ mt: 1, flexGrow: 1 }}>{shortText(r.preparacion, 100)}</Typography>
                
                <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <Typography variant="caption" color="text.secondary">{r.fechaCreacion}</Typography>
                  <Box>
                    <IconButton size="small" onClick={() => handleLike(r.idReceta || r.id)} aria-label="like">
                      {userInteractions.likes.has(r.idReceta || r.id) ? <ThumbUpIcon fontSize="small" color="primary" /> : <ThumbUpOutlinedIcon fontSize="small" />}
                    </IconButton>
                    <IconButton size="small" onClick={() => handleOpenRating(r.idReceta || r.id, r.nombre)} aria-label="star">
                      {userInteractions.estrellas.has(r.idReceta || r.id) ? <StarIcon fontSize="small" color="warning" /> : <StarBorderIcon fontSize="small" />}
                    </IconButton>
                    <IconButton size="small" onClick={() => handleFavorito(r.idReceta || r.id)} aria-label="fav">
                      {userInteractions.favoritos.has(r.idReceta || r.id) ? <BookmarkIcon fontSize="small" color="error" /> : <BookmarkBorderIcon fontSize="small" />}
                    </IconButton>
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
            <Typography sx={{ mt: 2, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Ingredientes</Typography>
            <Box component="ul" sx={{ pl: 2, mt: 1, mb: 2 }}>
              {(selectedReceta?.ingredientes || []).map(i => (
                <Box component="li" key={i.idIngrediente} sx={{ listStyleType: 'disc', ml: 1, fontSize: '0.95rem' }}>{i.nombre}</Box>
              ))}
            </Box>
            <Typography sx={{ mt: 2, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Preparación</Typography>
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
                <IconButton aria-label="star" onClick={() => handleOpenRating(selectedReceta?.idReceta || selectedReceta?.id, selectedReceta?.nombre)}>
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
        <RatingDialog 
          open={ratingDialogOpen} 
          onClose={() => setRatingDialogOpen(false)} 
          onRate={handleRate}
          recetaNombre={ratingRecetaNombre}
        />
      </Container>
    </Box>
  );
}
