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
import Drawer from '@mui/material/Drawer';
import Autocomplete from '@mui/material/Autocomplete';
import FilterListIcon from '@mui/icons-material/FilterList';
import CloseIcon from '@mui/icons-material/Close';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import { searchRecetasByNombre, postLikeReceta, deleteLikeReceta, postStarReceta, deleteStarReceta, postFavoritoReceta, deleteFavoritoReceta, getComentariosReceta, postComentarioReceta, isAuthenticated, getMeGustaCount, getEstrellaStats, getMeGustas, getEstrellas, getFavoritos, getPaises, getCategorias, formatFecha, getUserNombre, isAdmin } from '../api';
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
  const rows = 10; // 10 filas
  const theme = useTheme();
  const isMd = useMediaQuery(theme.breakpoints.up('md'));
  const isSm = useMediaQuery(theme.breakpoints.up('sm'));
  const columns = isMd ? 2 : (isSm ? 2 : 1); // 2 columnas en tablet/desktop, 1 en móvil
  const perPage = rows * columns; // 20 recetas en tablet/desktop, 10 en móvil

  useEffect(()=>{ setPage(1); },[columns, q]);

  const shortText = (text, n=140) => text ? (text.length>n? text.slice(0,n).trim()+'...': text) : '';

  const [openReceta, setOpenReceta] = useState(false);
  const [selectedReceta, setSelectedReceta] = useState(null);
  const [comentarios, setComentarios] = useState([]);
  const [newComentario, setNewComentario] = useState('');
  const [authPromptOpen, setAuthPromptOpen] = useState(false);
  const [userInteractions, setUserInteractions] = useState({ likes: new Set(), favoritos: new Set(), estrellas: new Map() });
  const [modalStats, setModalStats] = useState({ likesCount: 0, avgStars: 0, totalStars: 0 });
  const [ratingDialogOpen, setRatingDialogOpen] = useState(false);
  const [currentRatingRecetaId, setCurrentRatingRecetaId] = useState(null);

  // Estados para filtros
  const [filterDrawerOpen, setFilterDrawerOpen] = useState(false);
  const [paises, setPaises] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [selectedPais, setSelectedPais] = useState(null);
  const [selectedCategoria, setSelectedCategoria] = useState(null);
  const [sortByStars, setSortByStars] = useState('');
  const [recetasWithStars, setRecetasWithStars] = useState(new Map());
  const [fechaDesde, setFechaDesde] = useState('');
  const [fechaHasta, setFechaHasta] = useState('');

  // Estados temporales para filtros (solo en el drawer)
  const [tempSelectedPais, setTempSelectedPais] = useState(null);
  const [tempSelectedCategoria, setTempSelectedCategoria] = useState(null);
  const [tempSortByStars, setTempSortByStars] = useState('');
  const [tempFechaDesde, setTempFechaDesde] = useState('');
  const [tempFechaHasta, setTempFechaHasta] = useState('');


  // Cargar países y categorías para los filtros
  useEffect(() => {
    Promise.all([
      getPaises().catch(() => ({ data: [] })),
      getCategorias().catch(() => ({ data: [] }))
    ]).then(([paisesRes, categoriasRes]) => {
      setPaises(paisesRes?.data || []);
      setCategorias(categoriasRes?.data || []);
    });
  }, []);

  // Cargar estadísticas de estrellas cuando se activa el ordenamiento
  useEffect(() => {
    if(sortByStars && recetas.length > 0) {
      loadAllRecetasStars(recetas);
    }
  }, [sortByStars, recetas.length]);

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
      
      // Obtener nombres de usuarios para cada comentario
      const comentariosConNombres = await Promise.all(
        list.map(async (comentario) => {
          // Intentar obtener el ID del usuario de diferentes campos posibles
          const userId = comentario.usuario?.idUsr || comentario.idUsuario || comentario.idUsr || comentario.usuario_id || comentario.userId;
          
          if (!userId) {
            return {
              ...comentario,
              nombreUsuario: 'Usuario'
            };
          }
          
          try {
            const nombreResponse = await getUserNombre(userId);
            return {
              ...comentario,
              nombreUsuario: nombreResponse?.data?.nombre || nombreResponse?.nombre || 'Usuario'
            };
          } catch (error) {
            console.error('Error obteniendo nombre de usuario:', error);
            return {
              ...comentario,
              nombreUsuario: 'Usuario'
            };
          }
        })
      );
      
      setComentarios(comentariosConNombres);
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
    setCurrentRatingRecetaId(recetaId);
    setRatingDialogOpen(true);
  };

  const handleOpenRating = (recetaId) => {
    if(!isAuthenticated()){ setAuthPromptOpen(true); return; }
    setCurrentRatingRecetaId(recetaId);
    setRatingDialogOpen(true);
  };

  const handleRateSubmit = async (rating) => {
    if (!currentRatingRecetaId) return;
    try {
      await postStarReceta(currentRatingRecetaId, rating);
      setUserInteractions(prev => {
        const newEstrellas = new Map(prev.estrellas);
        newEstrellas.set(currentRatingRecetaId, rating);
        return { ...prev, estrellas: newEstrellas };
      });
      if(openReceta && (selectedReceta?.idReceta === currentRatingRecetaId || selectedReceta?.id === currentRatingRecetaId)) {
        loadModalStats(currentRatingRecetaId);
      }
    } catch(e) {}
  };

  const handleDeleteRating = async () => {
    if (!currentRatingRecetaId) return;
    try {
      const estrellaActual = userInteractions.estrellas.get(currentRatingRecetaId);
      if(estrellaActual) {
        // Obtener todas las estrellas del usuario para encontrar el idEstrella
        const estrellasRes = await getEstrellas();
        const estrellasData = estrellasRes?.data || estrellasRes || [];
        const starsList = Array.isArray(estrellasData) ? estrellasData : (Array.isArray(estrellasData?.estrellas) ? estrellasData.estrellas : []);
        
        const miEstrella = starsList.find(e => {
          const recetaId = e.idReceta || e.receta_id || e.id_receta || e.receta?.idReceta || e.receta?.id;
          return recetaId === currentRatingRecetaId;
        });
        
        if(miEstrella && (miEstrella.idEstrella || miEstrella.id)) {
          await deleteStarReceta(miEstrella.idEstrella || miEstrella.id);
          setUserInteractions(prev => {
            const newEstrellas = new Map(prev.estrellas);
            newEstrellas.delete(currentRatingRecetaId);
            return { ...prev, estrellas: newEstrellas };
          });
          if(openReceta && (selectedReceta?.idReceta === currentRatingRecetaId || selectedReceta?.id === currentRatingRecetaId)) {
            loadModalStats(currentRatingRecetaId);
          }
        }
      }
    } catch(e) {}
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

  // Aplicar filtros
  const filteredRecetas = recetas.filter(r => {
    // Filtro por país
    if(selectedPais) {
      const recetaPaisId = r.idPais || r.id_pais || r.pais?.idPais || r.pais?.id;
      const selectedPaisId = selectedPais.idPais || selectedPais.id;
      if(recetaPaisId !== selectedPaisId) {
        return false;
      }
    }
    
    // Filtro por categoría
    if(selectedCategoria) {
      const recetaCategoriaId = r.idCat || r.idCategoria || r.id_categoria || r.categoria?.idCat || r.categoria?.idCategoria || r.categoria?.id;
      const selectedCategoriaId = selectedCategoria.idCat || selectedCategoria.idCategoria || selectedCategoria.id;
      if(recetaCategoriaId !== selectedCategoriaId) {
        return false;
      }
    }
    
    // Filtro por rango de fechas
    if(fechaDesde || fechaHasta) {
      const recetaFecha = r.fechaCreacion || r.fecha_creacion;
      if(recetaFecha) {
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
      return starsA - starsB;
    } else if(sortByStars === 'desc') {
      return starsB - starsA;
    }
    return 0;
  }) : filteredRecetas;

  // Funciones para manejar filtros
  const handleApplyFilters = () => {
    // Aplicar los filtros temporales a los filtros reales
    setSelectedPais(tempSelectedPais);
    setSelectedCategoria(tempSelectedCategoria);
    setSortByStars(tempSortByStars);
    setFechaDesde(tempFechaDesde);
    setFechaHasta(tempFechaHasta);
    setFilterDrawerOpen(false);
    setPage(1); // Resetear a la primera página al aplicar filtros
  };

  const handleResetFilters = () => {
    setTempSelectedPais(null);
    setTempSelectedCategoria(null);
    setTempSortByStars('');
    setTempFechaDesde('');
    setTempFechaHasta('');
    setSelectedPais(null);
    setSelectedCategoria(null);
    setSortByStars('');
    setFechaDesde('');
    setFechaHasta('');
    setPage(1);
  };
  
  const handleOpenFilterDrawer = () => {
    // Sincronizar los estados temporales con los actuales al abrir el drawer
    setTempSelectedPais(selectedPais);
    setTempSelectedCategoria(selectedCategoria);
    setTempSortByStars(sortByStars);
    setTempFechaDesde(fechaDesde);
    setTempFechaHasta(fechaHasta);
    setFilterDrawerOpen(true);
  };

  return (
    <Box>
      <Box sx={{ 
        background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
        py: { xs: 4, md: 6 }
      }}>
        <Container>
          <Box textAlign="center">
            <Typography variant="h3" sx={{ 
              color: 'white', 
              fontFamily: 'Lato, sans-serif', 
              fontWeight: 900,
              textShadow: '2px 2px 4px rgba(0,0,0,0.2)',
              fontSize: { xs: '2rem', sm: '2.5rem', md: '3rem' }
            }} id="nombreBusqueda">
              Resultados de búsqueda
            </Typography>
            <Typography sx={{
              color: 'white',
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 600,
              fontSize: { xs: '1rem', sm: '1.1rem', md: '1.2rem' },
              mt: 1,
              textShadow: '1px 1px 2px rgba(0,0,0,0.1)'
            }}>
              "{q}"
            </Typography>
          </Box>
        </Container>
      </Box>
  <Container maxWidth="xl" sx={{ py: { xs: 3, md: 5 }, px: 2, mx: 'auto' }}>
        {loading && <Typography sx={{ textAlign: 'center', color: '#667EEA', fontFamily: 'Open Sans, sans-serif' }}>Buscando...</Typography>}
        {error && <Typography color="error" sx={{ textAlign: 'center' }}>{error}</Typography>}

        <Box sx={{ mb: 3, display: 'flex', justifyContent: 'flex-start', gap: 2, alignItems: 'center', flexWrap: 'wrap' }}>
          <Button 
            variant="contained" 
            startIcon={<FilterListIcon />} 
            onClick={handleOpenFilterDrawer}
            size="medium"
            sx={{ 
              background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
              color: 'white',
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 700,
              borderRadius: 50,
              px: 3,
              boxShadow: '0 4px 12px rgba(102, 126, 234, 0.3)',
              '&:hover': { 
                background: 'linear-gradient(135deg, #764BA2 0%, #667EEA 100%)',
                boxShadow: '0 6px 16px rgba(102, 126, 234, 0.4)',
                transform: 'translateY(-2px)'
              },
              transition: 'all 0.3s ease'
            }}
          >
            Filtros
          </Button>
          <TextField 
            size="small" 
            value={q} 
            disabled 
            sx={{ 
              minWidth: 300,
              '& .MuiOutlinedInput-root': {
                borderRadius: 50,
                backgroundColor: 'white'
              }
            }} 
          />
        </Box>

        <Grid container spacing={3} columns={12}>
          {recetas.length === 0 && !loading && (
            <Grid item xs={12}>
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
                  No se encontraron recetas.
                </Typography>
              </Box>
            </Grid>
          )}
          {sortedRecetas.slice((page-1)*perPage, page*perPage).map(r => {
            const recetaId = r.idReceta || r.id;
            return (
              <Grid 
                item 
                key={recetaId} 
                xs={6}
                sx={{
                  maxWidth: 'calc(50% - 12px)',
                  flexBasis: 'calc(50% - 12px)',
                  flexGrow: 0,
                  flexShrink: 0
                }}
              >
              <Box sx={{ 
                backgroundColor: 'white',
                borderRadius: 3,
                overflow: 'hidden',
                width: '100%',
                height: 520,
                display: 'flex', 
                flexDirection: 'column',
                boxShadow: '0 4px 12px rgba(102, 126, 234, 0.1)',
                transition: 'all 0.3s ease',
                '&:hover': {
                  transform: 'translateY(-8px)',
                  boxShadow: '0 8px 24px rgba(102, 126, 234, 0.2)'
                }
              }}>
                <Box sx={{ 
                  width: '100%', 
                  height: 300,
                  overflow: 'hidden',
                  flexShrink: 0,
                  backgroundColor: '#f5f5f5',
                  position: 'relative'
                }}>
                  <Box 
                    component="img" 
                    src={r.urlImagen || 'https://placehold.co/600x360'} 
                    alt={r.nombre} 
                    onError={(e)=>{ e.target.src='https://placehold.co/600x360'; }} 
                    sx={{ 
                      position: 'absolute',
                      top: 0,
                      left: 0,
                      width: '100%',
                      height: '100%',
                      objectFit: 'cover'
                    }} 
                  />
                </Box>
                <Box sx={{ p: 2.5, flexGrow: 1, display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
                  <Typography sx={{ 
                    fontFamily: 'Lato, sans-serif', 
                    fontWeight: 900,
                    color: '#1A202C',
                    fontSize: '1.1rem',
                    mb: 2,
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    display: '-webkit-box',
                    WebkitLineClamp: 2,
                    WebkitBoxOrient: 'vertical',
                    minHeight: '2.6em'
                  }}>
                    {r.nombre}
                  </Typography>
                  <Box>
                    <Typography variant="caption" sx={{ 
                      color: '#969696', 
                      fontFamily: 'Open Sans, sans-serif',
                      display: 'block',
                      mb: 1
                    }}>
                      {formatFecha(r.fechaCreacion)}
                    </Typography>
                    <Box sx={{ display: 'flex', gap: 0.5, justifyContent: 'flex-start' }}>
                      <IconButton 
                        size="small" 
                        onClick={() => handleLike(recetaId)} 
                        aria-label="like"
                        sx={{
                          backgroundColor: userInteractions.likes.has(recetaId) ? '#4299E1' : '#F7FAFC',
                          color: userInteractions.likes.has(recetaId) ? 'white' : '#4299E1',
                          '&:hover': {
                            backgroundColor: '#4299E1',
                            color: 'white'
                          }
                        }}
                      >
                        {userInteractions.likes.has(recetaId) ? <ThumbUpIcon fontSize="small" /> : <ThumbUpOutlinedIcon fontSize="small" />}
                      </IconButton>
                      <IconButton 
                        size="small" 
                        onClick={() => handleStar(recetaId)} 
                        aria-label="star"
                        sx={{
                          backgroundColor: userInteractions.estrellas.has(recetaId) ? '#ED8936' : '#F7FAFC',
                          color: userInteractions.estrellas.has(recetaId) ? 'white' : '#ED8936',
                          '&:hover': {
                            backgroundColor: '#ED8936',
                            color: 'white'
                          }
                        }}
                      >
                        {userInteractions.estrellas.has(recetaId) ? <StarIcon fontSize="small" /> : <StarBorderIcon fontSize="small" />}
                      </IconButton>
                      <IconButton 
                        size="small" 
                        onClick={() => handleFavorito(recetaId)} 
                        aria-label="fav"
                        sx={{
                          backgroundColor: userInteractions.favoritos.has(recetaId) ? '#F56565' : '#F7FAFC',
                          color: userInteractions.favoritos.has(recetaId) ? 'white' : '#F56565',
                          '&:hover': {
                            backgroundColor: '#F56565',
                            color: 'white'
                          }
                        }}
                      >
                        {userInteractions.favoritos.has(recetaId) ? <BookmarkIcon fontSize="small" /> : <BookmarkBorderIcon fontSize="small" />}
                      </IconButton>
                    </Box>
                  </Box>
                  <Button 
                    onClick={() => handleOpenReceta(r)} 
                    fullWidth
                    variant="contained"
                    sx={{
                      mt: 2,
                      background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
                      color: 'white',
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 700,
                      borderRadius: 50,
                      py: { xs: 0.8, sm: 1 },
                      fontSize: { xs: '0.875rem', sm: '0.9375rem' },
                      '&:hover': {
                        background: 'linear-gradient(135deg, #F5576C 0%, #F093FB 100%)',
                        transform: 'translateY(-2px)',
                        boxShadow: '0 4px 12px rgba(240, 147, 251, 0.4)'
                      },
                      transition: 'all 0.3s ease'
                    }}
                  >
                    Ver receta
                  </Button>
                </Box>
              </Box>
            </Grid>
            );
          })}
        </Grid>

        {sortedRecetas.length > perPage && (
          <Box sx={{ display: 'flex', justifyContent: 'center', mt: 3 }}>
            <Pagination count={Math.ceil(sortedRecetas.length / perPage)} page={page} onChange={(e, value) => setPage(value)} color="primary" />
          </Box>
        )}

        <Dialog open={openReceta} onClose={handleCloseReceta} fullWidth maxWidth="md">
        <DialogTitle sx={{ 
          fontFamily: 'Lato, sans-serif', 
          fontWeight: 900,
          color: '#1A202C',
          fontSize: { xs: '1.5rem', md: '1.75rem' },
          borderBottom: '3px solid rgba(102, 126, 234, 0.3)',
          pb: 2
        }}>
          {selectedReceta?.nombre}
          {isAdmin() && (
            <Typography component="span" sx={{ ml: 2, fontSize: '0.9rem', color: '#718096', fontWeight: 400 }}>
              (ID: {selectedReceta?.idReceta || selectedReceta?.id})
            </Typography>
          )}
        </DialogTitle>
        <DialogContent dividers sx={{ p: { xs: 2, md: 3 } }}>
          <Box 
            component="img" 
            src={selectedReceta?.urlImagen || 'https://placehold.co/800x480'} 
            alt={selectedReceta?.nombre} 
            onError={(e)=>{ e.target.src='https://placehold.co/800x480'; }} 
            sx={{ 
              width: '100%', 
              height: { xs: 240, md: 360 }, 
              maxHeight: 480, 
              objectFit: 'cover', 
              borderRadius: 3,
              boxShadow: '0 4px 16px rgba(0,0,0,0.15)'
            }} 
          />
          <Typography sx={{ 
            mt: 3, 
            fontFamily: 'Roboto, sans-serif', 
            fontWeight: 900,
            color: '#99682E',
            fontSize: '1.25rem'
          }}>
            Ingredientes
          </Typography>
          <Box component="ul" sx={{ pl: 3, mt: 1.5, mb: 3 }}>
            {(selectedReceta?.ingredientes || []).map((ingrediente, idx) => {
              const nombreIng = typeof ingrediente === 'string' ? ingrediente : ingrediente?.nombre || '';
              return nombreIng.split('\n').filter(line => line.trim()).map((line, lineIdx) => (
                <Box 
                  component="li" 
                  key={`ing-${idx}-${lineIdx}`} 
                  sx={{ 
                    listStyleType: 'disc', 
                    ml: 1, 
                    fontSize: '0.95rem', 
                    color: '#969696', 
                    mb: 0.5,
                    fontFamily: 'Open Sans, sans-serif'
                  }}
                >
                  {line.trim()}
                </Box>
              ));
            })}
          </Box>
          <Typography sx={{ 
            mt: 3, 
            fontFamily: 'Roboto, sans-serif', 
            fontWeight: 900,
            color: '#99682E',
            fontSize: '1.25rem'
          }}>
            Preparación
          </Typography>
          <Typography sx={{ 
            whiteSpace: 'pre-wrap', 
            color: '#969696',
            fontFamily: 'Open Sans, sans-serif',
            lineHeight: 1.7,
            mt: 1.5
          }}>
            {selectedReceta?.preparacion}
          </Typography>
          <Divider sx={{ my: 3 }} />
          
          {/* Botones de interacción con estadísticas */}
          <Box sx={{ 
            display: 'flex', 
            alignItems: 'center', 
            justifyContent: 'space-between', 
            flexWrap: 'wrap', 
            gap: 2,
            backgroundColor: '#F9E9AE',
            borderRadius: 2,
            p: 2
          }}>
            {/* Botones e interacciones de izquierda */}
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              {/* Botón Me Gusta con contador */}
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                <IconButton 
                  aria-label="like" 
                  onClick={() => handleLike(selectedReceta?.idReceta || selectedReceta?.id)}
                  sx={{
                    backgroundColor: userInteractions.likes.has(selectedReceta?.idReceta || selectedReceta?.id) ? '#F75442' : 'white',
                    color: userInteractions.likes.has(selectedReceta?.idReceta || selectedReceta?.id) ? 'white' : '#F75442',
                    '&:hover': {
                      backgroundColor: '#FA968B',
                      color: 'white'
                    }
                  }}
                >
                  {userInteractions.likes.has(selectedReceta?.idReceta || selectedReceta?.id) ? <ThumbUpIcon /> : <ThumbUpOutlinedIcon />}
                </IconButton>
                <Typography variant="body2" sx={{ fontWeight: 700, color: '#2F4295' }}>
                  {modalStats.likesCount}
                </Typography>
              </Box>
              
              {/* Botón Estrellas con promedio */}
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                <IconButton 
                  aria-label="star" 
                  onClick={() => handleOpenRating(selectedReceta?.idReceta || selectedReceta?.id)}
                  sx={{
                    backgroundColor: userInteractions.estrellas.has(selectedReceta?.idReceta || selectedReceta?.id) ? '#99682E' : 'white',
                    color: userInteractions.estrellas.has(selectedReceta?.idReceta || selectedReceta?.id) ? 'white' : '#99682E',
                    '&:hover': {
                      backgroundColor: '#99682E',
                      color: 'white'
                    }
                  }}
                >
                  {userInteractions.estrellas.has(selectedReceta?.idReceta || selectedReceta?.id) ? <StarIcon /> : <StarBorderIcon />}
                </IconButton>
                <Typography variant="body2" sx={{ fontWeight: 700, color: '#2F4295' }}>
                  {modalStats.avgStars > 0 ? modalStats.avgStars.toFixed(1) : '0.0'}
                  <Typography component="span" variant="body2" sx={{ ml: 0.5, color: '#969696', fontWeight: 400 }}>
                    ({modalStats.totalStars})
                  </Typography>
                </Typography>
              </Box>
            </Box>
            
            {/* Botón Favorito a la derecha */}
            <IconButton 
              aria-label="fav" 
              onClick={() => handleFavorito(selectedReceta?.idReceta || selectedReceta?.id)}
              sx={{
                backgroundColor: userInteractions.favoritos.has(selectedReceta?.idReceta || selectedReceta?.id) ? '#F75442' : 'white',
                color: userInteractions.favoritos.has(selectedReceta?.idReceta || selectedReceta?.id) ? 'white' : '#F75442',
                '&:hover': {
                  backgroundColor: '#FA968B',
                  color: 'white'
                }
              }}
            >
              {userInteractions.favoritos.has(selectedReceta?.idReceta || selectedReceta?.id) ? <BookmarkIcon /> : <BookmarkBorderIcon />}
            </IconButton>
          </Box>
          
          <Typography sx={{ 
            fontWeight: 900, 
            mt: 3,
            fontFamily: 'Roboto, sans-serif',
            color: '#2F4295',
            fontSize: '1.15rem'
          }}>
            Comentarios
          </Typography>
          <List sx={{ mt: 1 }}>
            {(comentarios || []).map(c => (
              <ListItem 
                key={c.idComentario || c.id}
                sx={{
                  backgroundColor: '#F9E9AE',
                  borderRadius: 2,
                  mb: 1.5
                }}
              >
                <ListItemText 
                  primary={c.nombreUsuario || 'Usuario'} 
                  secondary={c.texto || c.comentario}
                  primaryTypographyProps={{
                    fontFamily: 'Roboto, sans-serif',
                    fontWeight: 700,
                    color: '#2F4295'
                  }}
                  secondaryTypographyProps={{
                    fontFamily: 'Open Sans, sans-serif',
                    color: '#969696'
                  }}
                />
              </ListItem>
            ))}
          </List>
          <Box sx={{ display: 'flex', gap: 1, mt: 2 }}>
            <TextField 
              size="small" 
              fullWidth 
              placeholder="Escribe un comentario..." 
              value={newComentario} 
              onChange={(e)=> setNewComentario(e.target.value)}
              sx={{
                '& .MuiOutlinedInput-root': {
                  borderRadius: 50,
                  backgroundColor: 'white',
                  '&:hover fieldset': {
                    borderColor: '#F75442'
                  },
                  '&.Mui-focused fieldset': {
                    borderColor: '#F75442'
                  }
                }
              }}
            />
            <Button 
              size="small" 
              variant="contained" 
              onClick={async ()=>{ 
                if(!isAuthenticated()){ 
                  setAuthPromptOpen(true); 
                  return; 
                } 
                if(!newComentario || !newComentario.trim()) return; 
                try{ 
                  await postComentarioReceta(selectedReceta?.idReceta || selectedReceta?.id, newComentario); 
                  setNewComentario(''); 
                  await loadComentarios(selectedReceta?.idReceta || selectedReceta?.id); 
                }catch(e){
                  console.error('Error posting comment:', e);
                } 
              }}
              sx={{
                background: 'linear-gradient(135deg, #F75442 0%, #FA968B 100%)',
                borderRadius: 50,
                px: 3,
                '&:hover': {
                  background: 'linear-gradient(135deg, #FA968B 0%, #F75442 100%)'
                }
              }}
            >
              Enviar
            </Button>
          </Box>
        </DialogContent>
        <DialogActions sx={{ p: 2 }}>
          <Button 
            onClick={handleCloseReceta}
            sx={{
              color: '#2F4295',
              fontWeight: 600,
              '&:hover': {
                backgroundColor: '#F9E9AE'
              }
            }}
          >
            Cerrar
          </Button>
        </DialogActions>
      </Dialog>
        <AuthPromptDialog open={authPromptOpen} onClose={()=> setAuthPromptOpen(false)} />
        
        <RatingDialog
          open={ratingDialogOpen}
          onClose={() => setRatingDialogOpen(false)}
          onRate={handleRateSubmit}
          onDelete={handleDeleteRating}
          recetaNombre={
            currentRatingRecetaId 
              ? recetas.find(r => (r.idReceta || r.id) === currentRatingRecetaId)?.nombre || selectedReceta?.nombre || 'Receta'
              : 'Receta'
          }
          hasRating={currentRatingRecetaId ? userInteractions.estrellas.has(currentRatingRecetaId) : false}
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

            {/* Filtro por Categoría */}
            <Autocomplete
              options={categorias}
              getOptionLabel={(option) => option.nombre || ''}
              value={tempSelectedCategoria}
              onChange={(event, newValue) => setTempSelectedCategoria(newValue)}
              renderInput={(params) => (
                <TextField {...params} label="Categoría" size="small" />
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
