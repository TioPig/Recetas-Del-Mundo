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
import Drawer from '@mui/material/Drawer';
import Autocomplete from '@mui/material/Autocomplete';
import FilterListIcon from '@mui/icons-material/FilterList';
import CloseIcon from '@mui/icons-material/Close';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import { getRecetasByCategoria, getCategoria, postLikeReceta, deleteLikeReceta, postStarReceta, deleteStarReceta, postFavoritoReceta, deleteFavoritoReceta, getComentariosReceta, postComentarioReceta, isAuthenticated, getEstrellaStats, getMeGustaCount, getFavoritos, getMeGustas, getEstrellas, getPaises, formatFecha } from '../api';
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
  
  // Estados para filtros - MOVER ANTES DE LOS useEffect
  const [filterDrawerOpen, setFilterDrawerOpen] = useState(false);
  const [paises, setPaises] = useState([]);
  const [selectedPais, setSelectedPais] = useState(null);
  const [searchNombre, setSearchNombre] = useState('');
  const [sortByStars, setSortByStars] = useState(''); // '', 'asc', 'desc'
  const [recetasWithStars, setRecetasWithStars] = useState(new Map()); // Map de idReceta -> promedio estrellas
  const [fechaDesde, setFechaDesde] = useState('');
  const [fechaHasta, setFechaHasta] = useState('');
  
  // Estados temporales para filtros (solo en el drawer)
  const [tempSelectedPais, setTempSelectedPais] = useState(null);
  const [tempSearchNombre, setTempSearchNombre] = useState('');
  const [tempSortByStars, setTempSortByStars] = useState('');
  const [tempFechaDesde, setTempFechaDesde] = useState('');
  const [tempFechaHasta, setTempFechaHasta] = useState('');
  
  // Otros estados
  const [selectedReceta, setSelectedReceta] = useState(null);
  const [authPromptOpen, setAuthPromptOpen] = useState(false);
  const [ratingDialogOpen, setRatingDialogOpen] = useState(false);
  const [ratingRecetaId, setRatingRecetaId] = useState(null);
  const [ratingRecetaNombre, setRatingRecetaNombre] = useState('');
  const [userInteractions, setUserInteractions] = useState({ likes: new Set(), favoritos: new Set(), estrellas: new Map() });
  const [modalStats, setModalStats] = useState({ likesCount: 0, avgStars: 0, totalStars: 0 }); // Estadísticas del modal
  const [comentarios, setComentarios] = useState([]);
  const [newComentario, setNewComentario] = useState('');

  useEffect(()=>{
    setLoading(true);
    Promise.all([getRecetasByCategoria(id), getCategoria(id)])
      .then(([rRecetas, rCat])=>{
        const data = rRecetas && rRecetas.data ? rRecetas.data : rRecetas;
        const list = Array.isArray(data) ? data : (Array.isArray(data?.recetas) ? data.recetas : (Array.isArray(data?.items) ? data.items : []));
        setRecetas(list);
        setCat(rCat && rCat.data ? rCat.data : null);
        setError(null);
        
        // NO cargar estadísticas al listar - solo en el modal
        
        // Cargar estadísticas de estrellas para ordenamiento si está activo
        if(sortByStars) {
          loadAllRecetasStars(list);
        }
        
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

  // Cargar países para el filtro
  useEffect(() => {
    getPaises()
      .then(res => {
        const paisesData = res?.data || [];
        setPaises(paisesData);
      })
      .catch(err => console.error('Error cargando países:', err));
  }, []);

  // Cargar estadísticas de estrellas cuando se activa el ordenamiento
  useEffect(() => {
    if(sortByStars && recetas.length > 0) {
      loadAllRecetasStars(recetas);
    }
  }, [sortByStars]);

  // Función para cargar estadísticas de estrellas de todas las recetas
  const loadAllRecetasStars = async (recetasList) => {
    try {
      const starsMap = new Map();
      const promises = recetasList.map(async (receta) => {
        const recetaId = receta.idReceta || receta.id;
        try {
          const res = await getEstrellaStats(recetaId);
          const data = res?.data || res;
          const promedio = data?.promedio || data?.average || data?.avg || 0;
          starsMap.set(recetaId, promedio);
        } catch {
          starsMap.set(recetaId, 0);
        }
      });
      await Promise.all(promises);
      setRecetasWithStars(starsMap);
    } catch (e) {
      console.error('Error cargando estadísticas de estrellas:', e);
    }
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
      // Recargar estadísticas del modal si está abierto
      if(openReceta && (selectedReceta?.idReceta === ratingRecetaId || selectedReceta?.id === ratingRecetaId)) {
        loadModalStats(ratingRecetaId);
      }
    }catch(e){ console.error('Error al calificar:', e); }
  };

  const handleDeleteRating = async () => {
    if(!ratingRecetaId) return;
    try{
      // Obtener el ID de la estrella del usuario para esta receta
      const estrellaActual = userInteractions.estrellas.get(ratingRecetaId);
      if(estrellaActual) {
        // Necesitamos el ID de la estrella, no el valor
        // Por ahora, vamos a obtenerlo de getEstrellas
        const estrellasRes = await getEstrellas();
        const estrellasData = estrellasRes?.data || estrellasRes || [];
        const miEstrella = estrellasData.find(e => 
          (e.receta?.idReceta === ratingRecetaId || e.receta?.id === ratingRecetaId)
        );
        
        if(miEstrella && miEstrella.idEstrella) {
          await deleteStarReceta(miEstrella.idEstrella);
          setUserInteractions(prev => {
            const newEstrellas = new Map(prev.estrellas);
            newEstrellas.delete(ratingRecetaId);
            return { ...prev, estrellas: newEstrellas };
          });
          // Recargar estadísticas del modal si está abierto
          if(openReceta && (selectedReceta?.idReceta === ratingRecetaId || selectedReceta?.id === ratingRecetaId)) {
            loadModalStats(ratingRecetaId);
          }
        }
      }
    }catch(e){ console.error('Error al eliminar calificación:', e); }
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
    // Filtro por búsqueda del input principal
    if(search && search.trim()) {
      const s = search.trim().toLowerCase();
      if(!(r.nombre || '').toString().toLowerCase().includes(s)) {
        return false;
      }
    }
    
    // Filtro por búsqueda de nombre desde el drawer
    if(searchNombre && searchNombre.trim()) {
      const s = searchNombre.trim().toLowerCase();
      if(!(r.nombre || '').toString().toLowerCase().includes(s)) {
        return false;
      }
    }
    
    // Filtro por país
    if(selectedPais) {
      const recetaPaisId = r.idPais || r.id_pais || r.pais?.idPais || r.pais?.id;
      const selectedPaisId = selectedPais.idPais || selectedPais.id;
      if(recetaPaisId !== selectedPaisId) {
        return false;
      }
    }
    
    // Filtro por rango de fechas
    if(fechaDesde || fechaHasta) {
      const recetaFecha = r.fechaCreacion || r.fecha_creacion;
      if(recetaFecha) {
        // Convertir la fecha de la receta a formato Date
        const fechaReceta = new Date(recetaFecha);
        
        if(fechaDesde) {
          const desde = new Date(fechaDesde);
          desde.setHours(0, 0, 0, 0);
          if(fechaReceta < desde) {
            return false;
          }
        }
        
        if(fechaHasta) {
          const hasta = new Date(fechaHasta);
          hasta.setHours(23, 59, 59, 999);
          if(fechaReceta > hasta) {
            return false;
          }
        }
      }
    }
    
    return true;
  });

  // Aplicar ordenamiento por estrellas
  const sortedRecetas = sortByStars ? [...filteredRecetas].sort((a, b) => {
    const recetaIdA = a.idReceta || a.id;
    const recetaIdB = b.idReceta || b.id;
    const starsA = recetasWithStars.get(recetaIdA) || 0;
    const starsB = recetasWithStars.get(recetaIdB) || 0;
    
    if(sortByStars === 'asc') {
      return starsA - starsB; // Menor a mayor
    } else if(sortByStars === 'desc') {
      return starsB - starsA; // Mayor a menor
    }
    return 0;
  }) : filteredRecetas;

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

  // Funciones para manejar filtros
  const handleApplyFilters = () => {
    // Aplicar los filtros temporales a los filtros reales
    setSelectedPais(tempSelectedPais);
    setSearchNombre(tempSearchNombre);
    setSortByStars(tempSortByStars);
    setFechaDesde(tempFechaDesde);
    setFechaHasta(tempFechaHasta);
    setFilterDrawerOpen(false);
    setPage(1); // Resetear a la primera página al aplicar filtros
  };

  const handleResetFilters = () => {
    setTempSelectedPais(null);
    setTempSearchNombre('');
    setTempSortByStars('');
    setTempFechaDesde('');
    setTempFechaHasta('');
    setSelectedPais(null);
    setSearchNombre('');
    setSortByStars('');
    setFechaDesde('');
    setFechaHasta('');
    setPage(1);
  };
  
  const handleOpenFilterDrawer = () => {
    // Sincronizar los estados temporales con los actuales al abrir el drawer
    setTempSelectedPais(selectedPais);
    setTempSearchNombre(searchNombre);
    setTempSortByStars(sortByStars);
    setTempFechaDesde(fechaDesde);
    setTempFechaHasta(fechaHasta);
    setFilterDrawerOpen(true);
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
        <Box sx={{ mb: 2, display: 'flex', justifyContent: 'flex-start', gap: 2, alignItems: 'center' }}>
          <Button 
            variant="contained" 
            startIcon={<FilterListIcon />} 
            onClick={handleOpenFilterDrawer}
            size="small"
            sx={{ backgroundColor: '#F75442', '&:hover': { backgroundColor: '#d43f2f' } }}
          >
            Filtros
          </Button>
          <TextField size="small" placeholder="Buscar en estas recetas..." value={search} onChange={(e)=>{ setSearch(e.target.value); setPage(1); }} sx={{ minWidth: 300 }} />
        </Box>

        <Grid container spacing={2} id="recetas" justifyContent="center">
          {recetas.length === 0 && !loading && <Grid item xs={12}><Typography>No se encontraron recetas para esta categoría.</Typography></Grid>}
          {sortedRecetas.slice((page-1)*perPage, page*perPage).map(r => (
            <Grid item key={r.idReceta || r.id} sx={{ width: { xs: '100%', sm: '48%', md: '23%' } }}>
              <Box sx={{ border: '1px solid #eee', p: 2, borderRadius: 1, height: '100%', display: 'flex', flexDirection: 'column', boxSizing: 'border-box', width: '100%' }}>
                <Box component="img" src={r.urlImagen || 'https://placehold.co/600x360'} alt={r.nombre} onError={(e)=>{ e.target.src='https://placehold.co/600x360'; }} sx={{ width: '100%', height: 120, maxHeight: 140, objectFit: 'cover', borderRadius: 1 }} />
                <Typography sx={{ mt: 1, fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>{r.nombre}</Typography>
                <Typography color="text.secondary" sx={{ mt: 1, flexGrow: 1 }}>{shortText(r.preparacion, 100)}</Typography>
                
                <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <Typography variant="caption" color="text.secondary">{formatFecha(r.fechaCreacion)}</Typography>
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

        {sortedRecetas.length > perPage && (
          <Box sx={{ display: 'flex', justifyContent: 'center', mt: 3 }}>
            <Pagination count={Math.ceil(sortedRecetas.length / perPage)} page={page} onChange={(e, value) => setPage(value)} color="primary" />
          </Box>
        )}

        <Dialog open={openReceta} onClose={handleCloseReceta} fullWidth maxWidth="md">
            <DialogTitle sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>{selectedReceta?.nombre}</DialogTitle>
          <DialogContent dividers>
            <Box component="img" src={selectedReceta?.urlImagen || 'https://placehold.co/800x480'} alt={selectedReceta?.nombre} onError={(e)=>{ e.target.src='https://placehold.co/800x480'; }} sx={{ width: '100%', height: 360, maxHeight: 480, objectFit: 'cover', borderRadius: 1 }} />
            <Typography sx={{ mt: 2, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Ingredientes</Typography>
            <Box component="ul" sx={{ pl: 2, mt: 1, mb: 2 }}>
              {(selectedReceta?.ingredientes || []).map(ingrediente => 
                ingrediente.nombre.split('\n').filter(line => line.trim()).map((line, idx) => (
                  <Box component="li" key={`${ingrediente.idIngrediente}-${idx}`} sx={{ listStyleType: 'disc', ml: 1, fontSize: '0.95rem', color: 'text.secondary', mb: 0.5 }}>
                    {line.trim()}
                  </Box>
                ))
              )}
            </Box>
            <Typography sx={{ mt: 2, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Preparación</Typography>
            <Typography sx={{ whiteSpace: 'pre-wrap', color: 'text.secondary' }}>{selectedReceta?.preparacion}</Typography>
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
                <ListItem key={c.idComentario || c.id}><ListItemText primary={c.autor || c.usuario?.nombre || c.usuario?.email || c.nombre || 'Anon'} secondary={c.texto || c.comentario} /></ListItem>
              ))}
            </List>
            <Box sx={{ display: 'flex', gap: 1, mt: 1 }}>
              <TextField size="small" fullWidth placeholder="Escribe un comentario..." value={newComentario} onChange={(e)=> setNewComentario(e.target.value)} />
              <Button size="small" variant="contained" onClick={async ()=>{ if(!isAuthenticated()){ setAuthPromptOpen(true); return; } if(!newComentario || !newComentario.trim()) return; try{ await postComentarioReceta(selectedReceta?.idReceta || selectedReceta?.id, newComentario); setNewComentario(''); await loadComentarios(selectedReceta?.idReceta || selectedReceta?.id); }catch(e){} }}>Enviar</Button>
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
          onDelete={handleDeleteRating}
          recetaNombre={ratingRecetaNombre}
          hasRating={userInteractions.estrellas.has(ratingRecetaId)}
        />

        {/* Drawer de filtros */}
        <Drawer
          anchor="right"
          open={filterDrawerOpen}
          onClose={() => setFilterDrawerOpen(false)}
        >
          <Box sx={{ width: 300, p: 3 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
              <Typography variant="h6" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>
                Filtros
              </Typography>
              <IconButton size="small" onClick={() => setFilterDrawerOpen(false)}>
                <CloseIcon />
              </IconButton>
            </Box>

            <Divider sx={{ mb: 3 }} />

            {/* Filtro por nombre */}
            <TextField
              label="Buscar por nombre"
              size="small"
              fullWidth
              value={tempSearchNombre}
              onChange={(e) => setTempSearchNombre(e.target.value)}
              sx={{ mb: 2 }}
              placeholder="Nombre de la receta..."
            />

            {/* Filtro por País */}
            <Autocomplete
              options={paises}
              getOptionLabel={(option) => option.nombre || ''}
              value={tempSelectedPais}
              onChange={(event, newValue) => setTempSelectedPais(newValue)}
              renderInput={(params) => (
                <TextField {...params} label="País" size="small" />
              )}
              sx={{ mb: 2 }}
            />

            {/* Ordenar por estrellas */}
            <FormControl fullWidth size="small" sx={{ mb: 2 }}>
              <InputLabel>Ordenar por estrellas</InputLabel>
              <Select
                value={tempSortByStars}
                label="Ordenar por estrellas"
                onChange={(e) => setTempSortByStars(e.target.value)}
              >
                <MenuItem value="">Sin ordenar</MenuItem>
                <MenuItem value="asc">Menor a mayor ⭐</MenuItem>
                <MenuItem value="desc">Mayor a menor ⭐</MenuItem>
              </Select>
            </FormControl>

            {/* Filtro por rango de fechas */}
            <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 600, color: 'text.secondary' }}>
              Filtrar por fecha
            </Typography>
            
            <TextField
              label="Fecha desde"
              type="date"
              size="small"
              fullWidth
              value={tempFechaDesde}
              onChange={(e) => setTempFechaDesde(e.target.value)}
              sx={{ mb: 2 }}
              InputLabelProps={{
                shrink: true,
              }}
            />

            <TextField
              label="Fecha hasta"
              type="date"
              size="small"
              fullWidth
              value={tempFechaHasta}
              onChange={(e) => setTempFechaHasta(e.target.value)}
              sx={{ mb: 2 }}
              InputLabelProps={{
                shrink: true,
              }}
            />

            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1, mt: 3 }}>
              <Button 
                variant="contained" 
                fullWidth
                onClick={handleApplyFilters}
              >
                Aplicar Filtros
              </Button>
              <Button 
                variant="outlined" 
                fullWidth
                onClick={handleResetFilters}
              >
                Limpiar Filtros
              </Button>
            </Box>
          </Box>
        </Drawer>
      </Container>
    </Box>
  );
}
