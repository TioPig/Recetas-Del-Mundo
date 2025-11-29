import React, { useEffect, useState } from 'react';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import TextField from '@mui/material/TextField';
import Divider from '@mui/material/Divider';
import Pagination from '@mui/material/Pagination';
import Stack from '@mui/material/Stack';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import BookmarkBorderIcon from '@mui/icons-material/BookmarkBorder';
import ThumbUpIcon from '@mui/icons-material/ThumbUp';
import ThumbUpOutlinedIcon from '@mui/icons-material/ThumbUpOutlined';
import StarIcon from '@mui/icons-material/Star';
import StarBorderIcon from '@mui/icons-material/StarBorder';
import Drawer from '@mui/material/Drawer';
import Autocomplete from '@mui/material/Autocomplete';
import FilterListIcon from '@mui/icons-material/FilterList';
import CloseIcon from '@mui/icons-material/Close';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';
import { 
  getFavoritos, 
  isAuthenticated, 
  postFavoritoReceta, 
  deleteFavoritoReceta,
  postLikeReceta,
  deleteLikeReceta,
  postStarReceta,
  deleteStarReceta,
  getMeGustas,
  getEstrellas,
  getComentariosReceta,
  postComentarioReceta,
  getMeGustaCount,
  getEstrellaStats,
  getPaises,
  getCategorias,
  formatFecha,
  getUserNombre
} from '../api';
import AuthPromptDialog from './AuthPromptDialog';
import RatingDialog from './RatingDialog';

export default function UserFavoritos(){
  const theme = useTheme();
  const isMd = useMediaQuery(theme.breakpoints.up('md'));
  const isSm = useMediaQuery(theme.breakpoints.up('sm'));
  
  const [favoritos, setFavoritos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [authPromptOpen, setAuthPromptOpen] = useState(false);
  const [userInteractions, setUserInteractions] = useState({ 
    likes: new Set(), 
    favoritos: new Set(), 
    estrellas: new Map() 
  });
  const [ratingDialogOpen, setRatingDialogOpen] = useState(false);
  const [ratingRecetaId, setRatingRecetaId] = useState(null);
  const [ratingRecetaNombre, setRatingRecetaNombre] = useState('');
  const [openReceta, setOpenReceta] = useState(false);
  const [selectedReceta, setSelectedReceta] = useState(null);
  const [comentarios, setComentarios] = useState([]);
  const [newComentario, setNewComentario] = useState('');
  const [recetaStats, setRecetaStats] = useState({ likesCount: 0, avgStars: 0, totalStars: 0 });
  const [page, setPage] = useState(1);
  
  // Estados para filtros
  const [filterDrawerOpen, setFilterDrawerOpen] = useState(false);
  const [paises, setPaises] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [selectedPais, setSelectedPais] = useState(null);
  const [selectedCategoria, setSelectedCategoria] = useState(null);
  const [searchNombre, setSearchNombre] = useState('');
  const [sortByStars, setSortByStars] = useState('');
  const [recetasWithStars, setRecetasWithStars] = useState(new Map());
  const [fechaDesde, setFechaDesde] = useState('');
  const [fechaHasta, setFechaHasta] = useState('');
  
  // Estados temporales para filtros (solo en el drawer)
  const [tempSelectedPais, setTempSelectedPais] = useState(null);
  const [tempSelectedCategoria, setTempSelectedCategoria] = useState(null);
  const [tempSearchNombre, setTempSearchNombre] = useState('');
  const [tempSortByStars, setTempSortByStars] = useState('');
  const [tempFechaDesde, setTempFechaDesde] = useState('');
  const [tempFechaHasta, setTempFechaHasta] = useState('');
  
  const columns = isMd ? 4 : (isSm ? 2 : 1);
  const rows = 10;
  const perPage = rows * columns;

  useEffect(()=>{
    if(!isAuthenticated()) {
      setAuthPromptOpen(true);
      setLoading(false);
      return;
    }

    setLoading(true);
    
    // Cargar países y categorías para filtros
    Promise.all([
      getPaises().catch(() => ({ data: [] })),
      getCategorias().catch(() => ({ data: [] }))
    ]).then(([paisesRes, categoriasRes]) => {
      setPaises(paisesRes?.data || []);
      setCategorias(categoriasRes?.data || []);
    });
    
    // Cargar solo favoritos y datos de interacción del usuario (sin todas las recetas)
    Promise.all([
      getFavoritos().catch(() => ({ data: [] })),
      getMeGustas().catch(() => ({ data: [] })),
      getEstrellas().catch(() => ({ data: [] }))
    ]).then(([favRes, likesRes, estrellasRes]) => {
      // Obtener ID del usuario actual
      const user = JSON.parse(localStorage.getItem('user') || '{}');
      const currentUserId = user.id_usr || user.idUsr || user.id;

      // Procesar favoritos
      const favData = favRes && favRes.data ? favRes.data : favRes;
      const favList = Array.isArray(favData) ? favData : (favData?.favoritos || []);
      
      // Procesar likes - filtrar solo del usuario actual
      const likesData = Array.isArray(likesRes?.data) ? likesRes.data : [];
      const newLikes = new Set();
      likesData.forEach(like => {
        const userId = like.usuario?.idUsr || like.usuario?.id || like.idUsuario || like.idUsr;
        if(currentUserId && userId && userId === currentUserId) {
          const recetaId = like.idReceta || like.id_receta || like.receta?.idReceta || like.receta?.id;
          if(recetaId) newLikes.add(recetaId);
        }
      });
      
      // Procesar estrellas - filtrar solo del usuario actual
      const estrellasData = Array.isArray(estrellasRes?.data) ? estrellasRes.data : [];
      const newEstrellas = new Map();
      const newFavoritos = new Set();
      estrellasData.forEach(estrella => {
        const userId = estrella.usuario?.idUsr || estrella.usuario?.id || estrella.idUsuario || estrella.idUsr;
        if(currentUserId && userId && userId === currentUserId) {
          const recetaId = estrella.idReceta || estrella.id_receta || estrella.receta?.idReceta || estrella.receta?.id;
          const valor = estrella.estrellas || estrella.valorEstrellas || estrella.valor || 0;
          if(recetaId) newEstrellas.set(recetaId, valor);
        }
      });
      
      // Procesar IDs de favoritos - filtrar solo del usuario actual
      favList.forEach(fav => {
        const userId = fav.usuario?.idUsr || fav.usuario?.id || fav.idUsuario || fav.idUsr;
        if(currentUserId && userId && userId === currentUserId) {
          const recetaId = fav.idReceta || fav.id_receta || fav.receta?.idReceta || fav.receta?.id || fav.id;
          if(recetaId) newFavoritos.add(recetaId);
        }
      });
      
      setUserInteractions({
        likes: newLikes,
        favoritos: newFavoritos,
        estrellas: newEstrellas
      });
      
      setFavoritos(favList);
    }).catch((err) => {
      console.error('Error cargando favoritos:', err);
      setFavoritos([]);
    }).finally(() => {
      setLoading(false);
    });
  },[]);

  // Resetear página cuando cambie el número de columnas
  useEffect(() => {
    setPage(1);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [columns]);

  // Cargar estadísticas de estrellas cuando se activa el ordenamiento
  useEffect(() => {
    if(sortByStars && favoritos.length > 0) {
      const resolved = favoritos.map(f => f?.receta || f).filter(Boolean);
      loadAllRecetasStars(resolved);
    }
  }, [sortByStars, favoritos.length]);

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

  // Mapear favoritos a recetas - Los favoritos ya incluyen los datos de la receta
  const resolved = favoritos.map(f => {
    if(!f) return null;
    
    // Si el favorito tiene el objeto receta anidado, usarlo
    if(f.receta) {
      return {
        idReceta: f.receta.idReceta || f.receta.id,
        nombre: f.receta.nombre,
        urlImagen: f.receta.urlImagen,
        preparacion: f.receta.preparacion,
        ingredientes: f.receta.ingredientes || [],
        fechaCreacion: f.receta.fechaCreacion
      };
    }
    
    // Si los datos están en el nivel raíz del favorito
    const recetaId = f.idReceta || f.id_receta || f.id;
    if(!recetaId) return null;
    
    return {
      idReceta: recetaId,
      nombre: f.nombre || 'Receta no disponible',
      urlImagen: f.urlImagen || '',
      preparacion: f.preparacion || '',
      ingredientes: f.ingredientes || [],
      fechaCreacion: f.fechaCreacion
    };
  }).filter(Boolean);

  // Aplicar filtros
  const filteredFavoritos = resolved.filter(r => {
    // Filtro por nombre
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
  const sortedFavoritos = sortByStars ? [...filteredFavoritos].sort((a, b) => {
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
  }) : filteredFavoritos;

  const handleOpenReceta = async (receta) => {
    setSelectedReceta(receta);
    const recetaId = receta?.idReceta || receta?.id;
    
    // Cargar comentarios y estadísticas en paralelo
    Promise.all([
      loadComentarios(recetaId),
      loadRecetaStats(recetaId)
    ]);
    
    setOpenReceta(true);
  };

  const handleCloseReceta = () => {
    setOpenReceta(false);
    setSelectedReceta(null);
    setRecetaStats({ likesCount: 0, avgStars: 0, totalStars: 0 });
  };

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
    }catch(e){ 
      setComentarios([]); 
    }
  };

  const loadRecetaStats = async (recetaId) => {
    if(!recetaId) return;
    try {
      const [likesRes, starsRes] = await Promise.all([
        getMeGustaCount(recetaId).catch(() => ({ data: { count: 0 } })),
        getEstrellaStats(recetaId).catch(() => ({ data: { promedio: 0, total: 0 } }))
      ]);
      
      const likesData = likesRes?.data || likesRes;
      const starsData = starsRes?.data || starsRes;
      
      setRecetaStats({
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
      // Recargar estadísticas si el modal está abierto
      if(openReceta && (selectedReceta?.idReceta === recetaId || selectedReceta?.id === recetaId)) {
        loadRecetaStats(recetaId);
      }
    }catch(err){
      // Error silencioso
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
        // Eliminar de la lista visual de favoritos
        setFavoritos(prev => prev.filter(f => {
          const fId = f.idReceta || f.id_receta || f.receta?.idReceta || f.receta?.id || f.id;
          return String(fId) !== String(recetaId);
        }));
      }else{
        await postFavoritoReceta(recetaId);
        setUserInteractions(prev => {
          const newFavoritos = new Set(prev.favoritos);
          newFavoritos.add(recetaId);
          return { ...prev, favoritos: newFavoritos };
        });
      }
    }catch(err){
      // Error silencioso
    }
  };

  const handleStarClick = (recetaId, recetaNombre) => {
    if(!isAuthenticated()){ setAuthPromptOpen(true); return; }
    setRatingRecetaId(recetaId);
    setRatingRecetaNombre(recetaNombre);
    setRatingDialogOpen(true);
  };

  const handleRate = async (stars) => {
    if(!ratingRecetaId) return;
    try{
      await postStarReceta(ratingRecetaId, stars);
      setUserInteractions(prev => {
        const newEstrellas = new Map(prev.estrellas);
        newEstrellas.set(ratingRecetaId, stars);
        return { ...prev, estrellas: newEstrellas };
      });
      // Recargar estadísticas si el modal está abierto
      if(openReceta && (selectedReceta?.idReceta === ratingRecetaId || selectedReceta?.id === ratingRecetaId)) {
        loadRecetaStats(ratingRecetaId);
      }
    }catch(err){
      // Error silencioso
    }
  };

  const handleDeleteRating = async () => {
    if(!ratingRecetaId) return;
    try{
      const estrellaActual = userInteractions.estrellas.get(ratingRecetaId);
      if(estrellaActual) {
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
          if(openReceta && (selectedReceta?.idReceta === ratingRecetaId || selectedReceta?.id === ratingRecetaId)) {
            loadRecetaStats(ratingRecetaId);
          }
        }
      }
    }catch(err){
      // Error silencioso
    }
  };

  const shortText = (text, n=100) => text ? (text.length>n? text.slice(0,n).trim()+'...': text) : '';

  // Funciones para manejar filtros
  const handleApplyFilters = () => {
    // Aplicar los filtros temporales a los filtros reales
    setSelectedPais(tempSelectedPais);
    setSelectedCategoria(tempSelectedCategoria);
    setSearchNombre(tempSearchNombre);
    setSortByStars(tempSortByStars);
    setFechaDesde(tempFechaDesde);
    setFechaHasta(tempFechaHasta);
    setFilterDrawerOpen(false);
    setPage(1); // Resetear a la primera página al aplicar filtros
  };

  const handleResetFilters = () => {
    setTempSelectedPais(null);
    setTempSelectedCategoria(null);
    setTempSearchNombre('');
    setTempSortByStars('');
    setTempFechaDesde('');
    setTempFechaHasta('');
    setSelectedPais(null);
    setSelectedCategoria(null);
    setSearchNombre('');
    setSortByStars('');
    setFechaDesde('');
    setFechaHasta('');
    setPage(1);
  };
  
  const handleOpenFilterDrawer = () => {
    // Sincronizar los estados temporales con los actuales al abrir el drawer
    setTempSelectedPais(selectedPais);
    setTempSelectedCategoria(selectedCategoria);
    setTempSearchNombre(searchNombre);
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
            }}>
              Tus Favoritos
            </Typography>
            <Typography sx={{
              color: 'white',
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 600,
              fontSize: { xs: '0.95rem', sm: '1rem', md: '1.1rem' },
              mt: 1,
              textShadow: '1px 1px 2px rgba(0,0,0,0.1)'
            }}>
              Todas tus recetas favoritas en un solo lugar
            </Typography>
          </Box>
        </Container>
      </Box>

      <Container maxWidth="xl" sx={{ py: { xs: 3, md: 5 }, px: 2, mx: 'auto' }}>
      {loading && <Typography>Cargando...</Typography>}
      
      {/* Botón de filtros */}
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'flex-start' }}>
        <Button 
          variant="contained" 
          startIcon={<FilterListIcon />} 
          onClick={handleOpenFilterDrawer}
          size="small"
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
      </Box>
      
      <Grid container spacing={3} justifyContent="flex-start">        {resolved.length === 0 && !loading && <Grid item xs={12}><Typography>No tienes favoritos aún.</Typography></Grid>}
        {sortedFavoritos.slice((page-1)*perPage, page*perPage).map(r => (
          <Grid item key={r.idReceta || r.id} xs={12} sm={6} sx={{ width: 'calc(50% - 12px)' }}>
            <Box sx={{ 
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
              {/* CONTENEDOR DE IMAGEN */}
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
              
              {/* CONTENIDO DE LA TARJETA */}
              <Box sx={{ 
                p: 2.5, 
                flexGrow: 1, 
                display: 'flex', 
                flexDirection: 'column', 
                justifyContent: 'space-between' 
              }}>
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
                      onClick={() => handleLike(r.idReceta || r.id)} 
                      aria-label="like"
                      sx={{
                        backgroundColor: userInteractions.likes.has(r.idReceta || r.id) ? '#4299E1' : '#F7FAFC',
                        color: userInteractions.likes.has(r.idReceta || r.id) ? 'white' : '#4299E1',
                        '&:hover': {
                          backgroundColor: '#4299E1',
                          color: 'white'
                        }
                      }}
                    >
                      {userInteractions.likes.has(r.idReceta || r.id) 
                        ? <ThumbUpIcon fontSize="small" /> 
                        : <ThumbUpOutlinedIcon fontSize="small" />
                      }
                    </IconButton>
                    <IconButton 
                      size="small" 
                      onClick={() => handleStarClick(r.idReceta || r.id, r.nombre)} 
                      aria-label="star"
                      sx={{
                        backgroundColor: userInteractions.estrellas.has(r.idReceta || r.id) ? '#ED8936' : '#F7FAFC',
                        color: userInteractions.estrellas.has(r.idReceta || r.id) ? 'white' : '#ED8936',
                        '&:hover': {
                          backgroundColor: '#ED8936',
                          color: 'white'
                        }
                      }}
                    >
                      {userInteractions.estrellas.has(r.idReceta || r.id)
                        ? <StarIcon fontSize="small" />
                        : <StarBorderIcon fontSize="small" />
                      }
                    </IconButton>
                    <IconButton 
                      size="small" 
                      onClick={() => handleFavorito(r.idReceta || r.id)} 
                      aria-label="fav"
                      sx={{
                        backgroundColor: userInteractions.favoritos.has(r.idReceta || r.id) ? '#F56565' : '#F7FAFC',
                        color: userInteractions.favoritos.has(r.idReceta || r.id) ? 'white' : '#F56565',
                        '&:hover': {
                          backgroundColor: '#F56565',
                          color: 'white'
                        }
                      }}
                    >
                      {userInteractions.favoritos.has(r.idReceta || r.id)
                        ? <BookmarkIcon fontSize="small" />
                        : <BookmarkBorderIcon fontSize="small" />
                      }
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
        ))}
      </Grid>

      {/* Paginación */}
      {sortedFavoritos.length > perPage && (
        <Box sx={{ display: 'flex', justifyContent: 'center', mt: 3 }}>
          <Pagination 
            count={Math.ceil(sortedFavoritos.length / perPage)} 
            page={page} 
            onChange={(e, value) => setPage(value)} 
            color="primary" 
          />
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
              objectFit: 'cover',
              borderRadius: 3,
              mb: 3,
              boxShadow: '0 4px 12px rgba(0,0,0,0.1)'
            }} 
          />
          
          <Typography variant="h6" sx={{ 
            fontFamily: 'Roboto, sans-serif', 
            fontWeight: 900,
            color: '#99682E',
            mb: 2,
            fontSize: '1.25rem'
          }}>
            Ingredientes
          </Typography>
          <Typography sx={{ 
            fontFamily: 'Open Sans, sans-serif', 
            color: '#969696',
            mb: 3,
            fontSize: '1rem',
            lineHeight: 1.7,
            whiteSpace: 'pre-wrap'
          }}>
            {selectedReceta?.ingredientes 
              ? (Array.isArray(selectedReceta.ingredientes) 
                  ? selectedReceta.ingredientes.map(ing => typeof ing === 'string' ? ing : ing.nombre).join(', ')
                  : selectedReceta.ingredientes)
              : 'No disponible'}
          </Typography>
          
          <Divider sx={{ my: 3 }} />
          
          <Typography variant="h6" sx={{ 
            fontFamily: 'Roboto, sans-serif', 
            fontWeight: 900,
            color: '#99682E',
            mb: 2,
            fontSize: '1.25rem'
          }}>
            Preparación
          </Typography>
          <Typography sx={{ 
            fontFamily: 'Open Sans, sans-serif', 
            color: '#969696',
            mb: 3,
            fontSize: '1rem',
            lineHeight: 1.7,
            whiteSpace: 'pre-wrap'
          }}>
            {selectedReceta?.preparacion || 'No disponible'}
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
                  {recetaStats.likesCount}
                </Typography>
              </Box>
              
              {/* Botón Estrellas con promedio */}
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                <IconButton 
                  aria-label="star" 
                  onClick={() => handleStarClick(selectedReceta?.idReceta || selectedReceta?.id, selectedReceta?.nombre)}
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
                  {recetaStats.avgStars > 0 ? recetaStats.avgStars.toFixed(1) : '0.0'}
                  <Typography component="span" variant="body2" sx={{ ml: 0.5, color: '#969696', fontWeight: 400 }}>
                    ({recetaStats.totalStars})
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
          
          
          <Typography variant="h6" sx={{ 
            fontFamily: 'Roboto, sans-serif', 
            fontWeight: 900,
            color: '#99682E',
            mb: 2,
            fontSize: '1.25rem'
          }}>
            Comentarios
          </Typography>
          
          {comentarios.length === 0 ? (
            <Typography sx={{ 
              fontFamily: 'Open Sans, sans-serif', 
              color: '#969696',
              fontStyle: 'italic',
              mb: 2
            }}>
              No hay comentarios aún. ¡Sé el primero en comentar!
            </Typography>
          ) : (
            <List sx={{ mb: 2 }}>
              {comentarios.map((c, idx) => (
                <ListItem 
                  key={idx} 
                  sx={{ 
                    backgroundColor: '#F9E9AE',
                    borderRadius: 2,
                    mb: 1,
                    flexDirection: 'column',
                    alignItems: 'flex-start'
                  }}
                >
                  <ListItemText
                    primary={
                      <Typography sx={{ 
                        fontFamily: 'Open Sans, sans-serif', 
                        fontWeight: 700,
                        color: '#1A202C',
                        fontSize: '0.95rem'
                      }}>
                        {c.nombreUsuario || 'Usuario'}
                      </Typography>
                    }
                    secondary={
                      <Typography sx={{ 
                        fontFamily: 'Open Sans, sans-serif', 
                        color: '#4A5568',
                        fontSize: '0.9rem',
                        mt: 0.5
                      }}>
                        {c.comentario || c.texto}
                      </Typography>
                    }
                  />
                  <Typography variant="caption" sx={{ 
                    color: '#718096',
                    fontFamily: 'Open Sans, sans-serif',
                    mt: 0.5
                  }}>
                    {formatFecha(c.fechaCreacion || c.fecha)}
                  </Typography>
                </ListItem>
              ))}
            </List>
          )}
          
          <Box sx={{ display: 'flex', gap: 1, mt: 2 }}>
            <TextField
              fullWidth
              size="small"
              placeholder="Escribe un comentario..."
              value={newComentario}
              onChange={(e) => setNewComentario(e.target.value)}
              sx={{
                '& .MuiOutlinedInput-root': {
                  borderRadius: 50,
                  borderColor: '#F75442',
                  fontFamily: 'Open Sans, sans-serif'
                }
              }}
            />
            <Button 
              size="small" 
              variant="contained" 
              onClick={async ()=>{ 
                if(!isAuthenticated()){ setAuthPromptOpen(true); return; } 
                if(!newComentario || !newComentario.trim()) return; 
              try{ 
                await postComentarioReceta(selectedReceta?.idReceta || selectedReceta?.id, newComentario); 
                setNewComentario(''); 
                await loadComentarios(selectedReceta?.idReceta || selectedReceta?.id); 
              }catch(e){
                // Error silencioso
              } 
            }}
              sx={{
                background: '#F75442',
                color: 'white',
                borderRadius: 50,
                px: 3,
                fontFamily: 'Open Sans, sans-serif',
                fontWeight: 700,
                boxShadow: 'none',
                '&:hover': {
                  background: '#d43f2f',
                  boxShadow: '0 4px 8px rgba(247, 84, 66, 0.3)'
                }
              }}
            >Enviar</Button>
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
