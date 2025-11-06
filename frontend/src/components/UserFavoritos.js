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
  formatFecha
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
      setComentarios(list);
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
      <Box className="hero-categorias" sx={{ backgroundColor: '#F6F0E0', py: 4 }}>
        <Container>
          <Box textAlign="center">
            <Typography variant="h2" sx={{ color: '#6b4f34', fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Tus Favoritos</Typography>
          </Box>
        </Container>
      </Box>

      <Container maxWidth="xl" sx={{ py: 4, px: 2, maxWidth: '1400px', mx: 'auto' }}>
      {loading && <Typography> Cargando... </Typography>}
      
      {/* Botón de filtros */}
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'flex-start' }}>
        <Button 
          variant="contained" 
          startIcon={<FilterListIcon />} 
          onClick={handleOpenFilterDrawer}
          size="small"
          sx={{ backgroundColor: '#F75442', '&:hover': { backgroundColor: '#d43f2f' } }}
        >
          Filtros
        </Button>
      </Box>
      
      <Grid container spacing={2} justifyContent="center">
        {resolved.length === 0 && !loading && <Grid item xs={12}><Typography>No tienes favoritos aún.</Typography></Grid>}
        {sortedFavoritos.slice((page-1)*perPage, page*perPage).map(r => (
          <Grid item key={r.idReceta || r.id} sx={{ width: { xs: '100%', sm: '48%', md: '23%' } }}>
            <Box sx={{ border: '1px solid #eee', p: 2, borderRadius: 1, height: '100%', display: 'flex', flexDirection: 'column', boxSizing: 'border-box', width: '100%' }}>
              <Box component="img" src={r.urlImagen || 'https://placehold.co/600x360'} alt={r.nombre} onError={(e)=>{ e.target.src='https://placehold.co/600x360'; }} sx={{ width: '100%', height: 120, maxHeight: 140, objectFit: 'cover', borderRadius: 1 }} />
              <Typography sx={{ mt: 1, fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>{r.nombre}</Typography>
              <Typography color="text.secondary" sx={{ mt: 1, flexGrow: 1, fontSize: '0.95rem' }}>{shortText(r.preparacion, 100)}</Typography>
              <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Typography variant="caption" color="text.secondary">{formatFecha(r.fechaCreacion)}</Typography>
                <Box>
                  <IconButton 
                    size="small" 
                    onClick={() => handleLike(r.idReceta || r.id)} 
                    aria-label="like"
                  >
                    {userInteractions.likes.has(r.idReceta || r.id) 
                      ? <ThumbUpIcon fontSize="small" color="primary" /> 
                      : <ThumbUpOutlinedIcon fontSize="small" />
                    }
                  </IconButton>
                  <IconButton 
                    size="small" 
                    onClick={() => handleStarClick(r.idReceta || r.id, r.nombre)} 
                    aria-label="star"
                  >
                    {userInteractions.estrellas.has(r.idReceta || r.id)
                      ? <StarIcon fontSize="small" color="warning" />
                      : <StarBorderIcon fontSize="small" />
                    }
                  </IconButton>
                  <IconButton 
                    size="small" 
                    onClick={() => handleFavorito(r.idReceta || r.id)} 
                    aria-label="fav"
                  >
                    {userInteractions.favoritos.has(r.idReceta || r.id)
                      ? <BookmarkIcon fontSize="small" color="error" />
                      : <BookmarkBorderIcon fontSize="small" />
                    }
                  </IconButton>
                  <Button onClick={() => handleOpenReceta(r)} size="small" sx={{ fontFamily: 'Open Sans, sans-serif' }}>Ver receta</Button>
                </Box>
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
                {recetaStats.likesCount}
              </Typography>
              
              {/* Botón Estrellas con promedio */}
              <IconButton aria-label="star" onClick={() => handleStarClick(selectedReceta?.idReceta || selectedReceta?.id, selectedReceta?.nombre)}>
                {userInteractions.estrellas.has(selectedReceta?.idReceta || selectedReceta?.id) ? <StarIcon color="warning" /> : <StarBorderIcon />}
              </IconButton>
              <Typography variant="body2" sx={{ fontWeight: 600 }}>
                {recetaStats.avgStars > 0 ? recetaStats.avgStars.toFixed(1) : '0.0'}
                <Typography component="span" variant="body2" sx={{ ml: 0.5, color: 'text.secondary', fontWeight: 400 }}>
                  ({recetaStats.totalStars})
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
              <ListItem key={c.idComentario || c.id}><ListItemText primary={c.autor || c.usuario?.nombre || c.usuario?.email || c.nombre || 'Anónimo'} secondary={c.texto || c.comentario} /></ListItem>
            ))}
          </List>
          <Box sx={{ display: 'flex', gap: 1, mt: 1 }}>
            <TextField size="small" fullWidth placeholder="Escribe un comentario..." value={newComentario} onChange={(e)=> setNewComentario(e.target.value)} />
            <Button size="small" variant="contained" onClick={async ()=>{ 
              if(!isAuthenticated()){ setAuthPromptOpen(true); return; } 
              if(!newComentario || !newComentario.trim()) return; 
              try{ 
                await postComentarioReceta(selectedReceta?.idReceta || selectedReceta?.id, newComentario); 
                setNewComentario(''); 
                await loadComentarios(selectedReceta?.idReceta || selectedReceta?.id); 
              }catch(e){
                // Error silencioso
              } 
            }}>Enviar</Button>
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
