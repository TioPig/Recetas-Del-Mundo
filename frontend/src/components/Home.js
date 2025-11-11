import React from 'react';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import IconButton from '@mui/material/IconButton';
import Rating from '@mui/material/Rating';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import TextField from '@mui/material/TextField';
import Divider from '@mui/material/Divider';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ThumbUpIcon from '@mui/icons-material/ThumbUp';
import ThumbUpOutlinedIcon from '@mui/icons-material/ThumbUpOutlined';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import BookmarkBorderIcon from '@mui/icons-material/BookmarkBorder';
import StarIcon from '@mui/icons-material/Star';
import StarOutlineIcon from '@mui/icons-material/StarOutline';
import StarBorderIcon from '@mui/icons-material/StarBorder';
import ArrowBackIosNewIcon from '@mui/icons-material/ArrowBackIosNew';
import ArrowForwardIosIcon from '@mui/icons-material/ArrowForwardIos';
import VisibilityIcon from '@mui/icons-material/Visibility';
import Button from '@mui/material/Button';
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import AuthPromptDialog from './AuthPromptDialog';
import RatingDialog from './RatingDialog';
import { 
  getPaises, 
  getRecetasTrending, 
  getRecetaDelDia,
  getMeGustaCount, 
  getEstrellaStats, 
  postLikeReceta, 
  deleteLikeReceta, 
  postFavoritoReceta, 
  deleteFavoritoReceta, 
  postStarReceta,
  getMeGustas,
  getEstrellas,
  getFavoritos,
  isAuthenticated,
  getComentariosReceta,
  postComentarioReceta,
  getUserNombre
} from '../api';
import { Link as RouterLink } from 'react-router-dom';export default function Home(){
  const navigate = useNavigate();
  const [paisesList, setPaisesList] = useState([]);
  const [carouselRecipes, setCarouselRecipes] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [userInteractions, setUserInteractions] = useState({
    likes: new Set(),
    favoritos: new Set(),
    estrellas: new Map()
  });
  const [recipeStats, setRecipeStats] = useState({
    likesCount: 0,
    avgStars: 0,
    totalStars: 0
  });
  
  // Estados para el modal
  const [selectedReceta, setSelectedReceta] = useState(null);
  const [openReceta, setOpenReceta] = useState(false);
  const [modalStats, setModalStats] = useState({ likesCount: 0, avgStars: 0, totalStars: 0 });
  const [comentarios, setComentarios] = useState([]);
  const [newComentario, setNewComentario] = useState('');
  const [authPromptOpen, setAuthPromptOpen] = useState(false);
  const [ratingDialogOpen, setRatingDialogOpen] = useState(false);
  const [ratingRecetaId, setRatingRecetaId] = useState(null);
  const [ratingRecetaNombre, setRatingRecetaNombre] = useState('');

  // Función auxiliar para truncar texto
  const truncateText = (text, maxLength) => {
    if (!text) return '';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
  };

  // Función para seleccionar la mejor receta según estadísticas
  const selectBestRecipe = (recipes) => {
    if (!recipes || recipes.length === 0) return null;
    
    // El backend ya envía ordenadas de menor a mayor (10 al 1)
    // Por lo tanto, la mejor receta es la ÚLTIMA del array (posición 9 si hay 10)
    return recipes[recipes.length - 1];
  };

  useEffect(()=>{
    getPaises().then(r=> setPaisesList(Array.isArray(r.data)?r.data:[])).catch(()=>{});
    
    // Load carousel recipes (trending + recipe of the day)
    Promise.all([
      getRecetasTrending(10).catch(()=>({ data: [] })),
      getRecetaDelDia().catch(()=>null)
    ]).then(([trendingRes, recetaDelDiaRes]) => {
      const trendingData = trendingRes && trendingRes.data ? trendingRes.data : trendingRes;
      const trendingList = Array.isArray(trendingData) ? trendingData : (Array.isArray(trendingData?.recetas) ? trendingData.recetas : (Array.isArray(trendingData?.items) ? trendingData.items : []));
      
      const recetaDelDiaData = recetaDelDiaRes && recetaDelDiaRes.data ? recetaDelDiaRes.data : recetaDelDiaRes;
      const recetaDelDia = Array.isArray(recetaDelDiaData) ? recetaDelDiaData[0] : recetaDelDiaData;
      
      const recipes = [];
      if(recetaDelDia) recipes.push({ ...recetaDelDia, isRecetaDelDia: true });
      
      // Seleccionar la mejor receta de las 10 trending
      const bestTrending = selectBestRecipe(trendingList);
      if(bestTrending) {
        recipes.push({ ...bestTrending, isRecetaDelDia: false });
      }
      
      setCarouselRecipes(recipes);
      
      // Load statistics for first recipe
      if(recipes.length > 0) {
        loadRecipeStats(recipes[0].idReceta || recipes[0].id);
      }
    });

    // Load user interactions if authenticated
    if(isAuthenticated()) {
      // Obtener ID del usuario actual
      const user = JSON.parse(localStorage.getItem('user') || '{}');
      const currentUserId = user.id_usr || user.idUsr || user.id;

      Promise.all([
        getMeGustas().catch(()=>({ data: [] })),
        getEstrellas().catch(()=>({ data: [] })),
        getFavoritos().catch(()=>({ data: [] }))
      ]).then(([likesRes, estrellasRes, favoritosRes]) => {
        const likesData = likesRes && likesRes.data ? likesRes.data : likesRes;
        const likesList = Array.isArray(likesData) ? likesData : (Array.isArray(likesData?.items) ? likesData.items : []);
        
        const estrellasData = estrellasRes && estrellasRes.data ? estrellasRes.data : estrellasRes;
        const estrellasList = Array.isArray(estrellasData) ? estrellasData : (Array.isArray(estrellasData?.items) ? estrellasData.items : []);
        
        const favoritosData = favoritosRes && favoritosRes.data ? favoritosRes.data : favoritosRes;
        const favoritosList = Array.isArray(favoritosData) ? favoritosData : (Array.isArray(favoritosData?.items) ? favoritosData.items : []);

        const likesSet = new Set();
        likesList.forEach(item => {
          // Filtrar solo los likes del usuario actual
          const userId = item.usuario?.idUsr || item.usuario?.id || item.idUsuario || item.idUsr;
          if(currentUserId && userId && userId === currentUserId) {
            const recetaId = item.idReceta || item.id_receta || item.receta?.idReceta || item.receta?.id || item.id;
            if(recetaId) {
              likesSet.add(recetaId);
            }
          }
        });

        const favoritosSet = new Set();
        favoritosList.forEach(item => {
          // Filtrar solo los favoritos del usuario actual
          const userId = item.usuario?.idUsr || item.usuario?.id || item.idUsuario || item.idUsr;
          if(currentUserId && userId && userId === currentUserId) {
            const recetaId = item.idReceta || item.id_receta || item.receta?.idReceta || item.receta?.id || item.id;
            if(recetaId) favoritosSet.add(recetaId);
          }
        });

        const estrellasMap = new Map();
        estrellasList.forEach(item => {
          // Filtrar solo las estrellas del usuario actual
          const userId = item.usuario?.idUsr || item.usuario?.id || item.idUsuario || item.idUsr;
          if(currentUserId && userId && userId === currentUserId) {
            const recetaId = item.idReceta || item.id_receta || item.receta?.idReceta || item.receta?.id || item.id;
            const valor = item.estrellas || item.valorEstrellas || item.valor || item.rating;
            if(recetaId && valor) estrellasMap.set(recetaId, valor);
          }
        });

        setUserInteractions({
          likes: likesSet,
          favoritos: favoritosSet,
          estrellas: estrellasMap
        });
      });
    }
  },[]);

  const loadRecipeStats = async (recetaId) => {
    if(!recetaId) return;
    try {
      const [likesRes, estrellasRes] = await Promise.all([
        getMeGustaCount(recetaId).catch(()=>({ data: 0 })),
        getEstrellaStats(recetaId).catch(()=>({ data: { promedio: 0, total: 0 } }))
      ]);

      const likesCount = likesRes && likesRes.data ? (likesRes.data.count || likesRes.data) : 0;
      const estrellasData = estrellasRes && estrellasRes.data ? estrellasRes.data : {};
      const avgStars = estrellasData.promedio || estrellasData.average || estrellasData.avg || 0;
      const totalStars = estrellasData.total || estrellasData.count || 0;

      setRecipeStats({
        likesCount: typeof likesCount === 'number' ? likesCount : 0,
        avgStars: typeof avgStars === 'number' ? avgStars : 0,
        totalStars: typeof totalStars === 'number' ? totalStars : 0
      });
    } catch (error) {
      console.error('Error loading recipe stats:', error);
    }
  };

  const handleLike = async (recetaId) => {
    if(!isAuthenticated()) {
      setAuthPromptOpen(true);
      return;
    }

    const isLiked = userInteractions.likes.has(recetaId);
    try {
      if(isLiked) {
        await deleteLikeReceta(recetaId);
        setUserInteractions(prev => {
          const newLikes = new Set(prev.likes);
          newLikes.delete(recetaId);
          return { ...prev, likes: newLikes };
        });
      } else {
        await postLikeReceta(recetaId);
        setUserInteractions(prev => {
          const newLikes = new Set(prev.likes);
          newLikes.add(recetaId);
          return { ...prev, likes: newLikes };
        });
      }
      loadRecipeStats(recetaId);
      
      // Recargar estadísticas del modal si está abierto
      if(openReceta && (selectedReceta?.idReceta === recetaId || selectedReceta?.id === recetaId)) {
        loadModalStats(recetaId);
      }
    } catch (error) {
      console.error('Error toggling like:', error);
    }
  };

  // Función para cargar estadísticas del modal
  const loadModalStats = async (recetaId) => {
    if(!recetaId) return;
    try {
      const [likesRes, estrellasRes] = await Promise.all([
        getMeGustaCount(recetaId).catch(()=>({ data: 0 })),
        getEstrellaStats(recetaId).catch(()=>({ data: { promedio: 0, total: 0 } }))
      ]);

      const likesCount = likesRes && likesRes.data ? (likesRes.data.count || likesRes.data) : 0;
      const estrellasData = estrellasRes && estrellasRes.data ? estrellasRes.data : {};
      const avgStars = estrellasData.promedio || estrellasData.average || estrellasData.avg || 0;
      const totalStars = estrellasData.total || estrellasData.count || 0;

      setModalStats({
        likesCount: typeof likesCount === 'number' ? likesCount : 0,
        avgStars: typeof avgStars === 'number' ? avgStars : 0,
        totalStars: typeof totalStars === 'number' ? totalStars : 0
      });
    } catch (error) {
      console.error('Error loading modal stats:', error);
    }
  };

  // Función para cargar comentarios
  const loadComentarios = async (recetaId) => {
    if(!recetaId) return;
    try {
      const response = await getComentariosReceta(recetaId);
      const data = response && response.data ? response.data : response;
      const comentariosList = Array.isArray(data) ? data : (Array.isArray(data?.comentarios) ? data.comentarios : []);
      
      // Obtener nombres de usuarios para cada comentario
      const comentariosConNombres = await Promise.all(
        comentariosList.map(async (comentario) => {
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
    } catch (error) {
      console.error('Error loading comentarios:', error);
      setComentarios([]);
    }
  };

  // Función para abrir el modal de receta
  const handleOpenReceta = async (receta) => {
    setSelectedReceta(receta);
    setOpenReceta(true);
    const recetaId = receta.idReceta || receta.id;
    await loadModalStats(recetaId);
    await loadComentarios(recetaId);
  };

  // Función para cerrar el modal
  const handleCloseReceta = () => {
    setSelectedReceta(null);
    setOpenReceta(false);
    setModalStats({ likesCount: 0, avgStars: 0, totalStars: 0 });
    setComentarios([]);
    setNewComentario('');
  };

  // Función para abrir el diálogo de rating
  const handleOpenRating = (recetaId, recetaNombre) => {
    if(!isAuthenticated()) {
      setAuthPromptOpen(true);
      return;
    }
    setRatingRecetaId(recetaId);
    setRatingRecetaNombre(recetaNombre);
    setRatingDialogOpen(true);
  };

  // Función para manejar el rating
  const handleRate = async (value) => {
    if(!ratingRecetaId) return;
    try {
      await postStarReceta(ratingRecetaId, value);
      setUserInteractions(prev => {
        const newEstrellas = new Map(prev.estrellas);
        newEstrellas.set(ratingRecetaId, value);
        return { ...prev, estrellas: newEstrellas };
      });
      
      // Recargar estadísticas del modal si está abierto
      if(openReceta && (selectedReceta?.idReceta === ratingRecetaId || selectedReceta?.id === ratingRecetaId)) {
        loadModalStats(ratingRecetaId);
      }
      
      setRatingDialogOpen(false);
    } catch (error) {
      console.error('Error rating recipe:', error);
    }
  };

  // Función para eliminar rating
  const handleDeleteRating = async () => {
    // Implementar si existe el endpoint para eliminar rating
    console.log('Delete rating for:', ratingRecetaId);
    setRatingDialogOpen(false);
  };

  const handleFavorite = async (recetaId) => {
    if(!isAuthenticated()) {
      setAuthPromptOpen(true);
      return;
    }

    const isFavorited = userInteractions.favoritos.has(recetaId);
    try {
      if(isFavorited) {
        await deleteFavoritoReceta(recetaId);
        setUserInteractions(prev => {
          const newFavoritos = new Set(prev.favoritos);
          newFavoritos.delete(recetaId);
          return { ...prev, favoritos: newFavoritos };
        });
      } else {
        await postFavoritoReceta(recetaId);
        setUserInteractions(prev => {
          const newFavoritos = new Set(prev.favoritos);
          newFavoritos.add(recetaId);
          return { ...prev, favoritos: newFavoritos };
        });
      }
    } catch (error) {
      console.error('Error toggling favorite:', error);
    }
  };

  const handleStar = async (recetaId) => {
    if(!isAuthenticated()) {
      alert('Debes iniciar sesión para calificar');
      return;
    }

    try {
      await postStarReceta(recetaId, 5);
      setUserInteractions(prev => {
        const newEstrellas = new Map(prev.estrellas);
        newEstrellas.set(recetaId, 5);
        return { ...prev, estrellas: newEstrellas };
      });
      loadRecipeStats(recetaId);
    } catch (error) {
      console.error('Error rating recipe:', error);
    }
  };

  const handlePrevious = () => {
    setCurrentIndex(prev => {
      const newIndex = prev > 0 ? prev - 1 : carouselRecipes.length - 1;
      const recipe = carouselRecipes[newIndex];
      if(recipe) loadRecipeStats(recipe.idReceta || recipe.id);
      return newIndex;
    });
  };

  const handleNext = () => {
    setCurrentIndex(prev => {
      const newIndex = prev < carouselRecipes.length - 1 ? prev + 1 : 0;
      const recipe = carouselRecipes[newIndex];
      if(recipe) loadRecipeStats(recipe.idReceta || recipe.id);
      return newIndex;
    });
  };

  const currentRecipe = carouselRecipes[currentIndex];

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
        <Box>
          <Box/>
        </Box>
          <Stack spacing={3} alignItems="center">
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <CheckCircleIcon sx={{ color: '#99682E', fontSize: 28 }} />
              <Typography variant="h5" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>Como funciona</Typography>
              <CheckCircleIcon sx={{ color: '#99682E', fontSize: 28 }} />
            </Box>

            <Box sx={{ display: 'flex', gap: 3, flexWrap: 'wrap', justifyContent: 'center', width: '100%' }}>
              <Box sx={{ textAlign: 'center', flexBasis: { xs: '100%', md: '30%' } }}>
                <Box component="img" src="/img/Eat-and-Enjoy-8.png" alt="acceso" sx={{ maxWidth: 150 }} />
                <Typography variant="h6" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>¿De donde puedes Acceder?</Typography>
                <Typography color="text.secondary" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 400 }}>Desde todas las partes del mundo, sin importar donde seas</Typography>
              </Box>

              <Box sx={{ textAlign: 'center', flexBasis: { xs: '100%', md: '30%' } }}>
                <Box component="img" src="/img/Meal-icon-8.png" alt="de-donde" sx={{ maxWidth: 150 }} />
                <Typography variant="h6" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>¿De donde?</Typography>
                <Typography color="text.secondary" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 400 }}>Gracias a la gran comunidad culinaria, podemos traer recetas desde cualquier parte del mundo</Typography>
              </Box>

              <Box sx={{ textAlign: 'center', flexBasis: { xs: '100%', md: '30%' } }}>
                <Box component="img" src="/img/Recurso-41-8.png" alt="ayuda" sx={{ maxWidth: 150 }} />
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
            <Box sx={{ flex: '1 1 30%', maxWidth: 385, borderBottom: '2px solid rgba(153,104,46,0.7)' }} />
            <CheckCircleIcon sx={{ color: '#99682E', fontSize: 28 }} />
            <Typography variant="h4" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>PAÍSES</Typography>
            <CheckCircleIcon sx={{ color: '#99682E', fontSize: 28 }} />
            <Box sx={{ flex: '1 1 30%', maxWidth: 385, borderBottom: '2px solid rgba(153,104,46,0.7)' }} />
          </Box>
          <Box sx={{ textAlign: 'center', mt: 2 }}>
            <PaisesPreview />
          </Box>
        </Box>
      </Container>

      {/* Divider between PAÍSES and RECETA TRENDING TOPIC */}
      <Container sx={{ py: 1 }}>
        <Box sx={{ display: 'flex', justifyContent: 'center', my: 2 }}>
          <Box sx={{ width: { xs: '95%', md: '88%' }, borderTop: '2px solid rgba(153,104,46,0.85)', borderRadius: 1 }} />
        </Box>
      </Container>

      {/* RECETA TRENDING TOPIC / RECETA DEL DÍA - CAROUSEL */}
      <Container sx={{ py: 4 }}>
        <Box sx={{ display: 'flex', gap: 3, alignItems: 'flex-start', flexWrap: { xs: 'wrap', md: 'nowrap' } }}>
          <Box sx={{ flex: '1 1 50%' }}>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
              <Typography variant="h5" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700, color: '#99682E' }}>
                {currentRecipe?.isRecetaDelDia ? 'Receta del Día 🌟' : 'Receta Trending Topic'}
              </Typography>
              <Box sx={{ display: 'flex', gap: 1 }}>
                <IconButton onClick={handlePrevious} disabled={carouselRecipes.length === 0} size="small">
                  <ArrowBackIosNewIcon />
                </IconButton>
                <Typography sx={{ display: 'flex', alignItems: 'center', fontWeight: 600 }}>
                  {carouselRecipes.length > 0 ? `${currentIndex + 1}/${carouselRecipes.length}` : '0/0'}
                </Typography>
                <IconButton onClick={handleNext} disabled={carouselRecipes.length === 0} size="small">
                  <ArrowForwardIosIcon />
                </IconButton>
              </Box>
            </Box>
            {currentRecipe ? (
              <>
                <Typography variant="h6" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700 }} id="recetaDelDiaNombre">{currentRecipe.nombre}</Typography>
                <Typography sx={{ mt: 1 }} id="recetaDelDiaDescripcion">
                  {truncateText(currentRecipe.descripcionCorta || currentRecipe.descripcion || '', 100)}
                </Typography>
                
                {/* Interactions and Statistics */}
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mt: 2, mb: 2, flexWrap: 'wrap', gap: 2 }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <IconButton onClick={() => handleLike(currentRecipe.idReceta || currentRecipe.id)} size="small">
                      {userInteractions.likes.has(currentRecipe.idReceta || currentRecipe.id) 
                        ? <ThumbUpIcon color="primary" /> 
                        : <ThumbUpOutlinedIcon />
                      }
                    </IconButton>
                    <Typography>{recipeStats.likesCount}</Typography>
                    
                    <IconButton onClick={() => handleOpenRating(currentRecipe.idReceta || currentRecipe.id, currentRecipe.nombre)} size="small">
                      {userInteractions.estrellas.has(currentRecipe.idReceta || currentRecipe.id) 
                        ? <StarIcon color="primary" /> 
                        : <StarOutlineIcon />
                      }
                    </IconButton>
                    <Typography>{recipeStats.avgStars.toFixed(1)} ({recipeStats.totalStars})</Typography>
                  </Box>
                  
                  <IconButton onClick={() => handleFavorite(currentRecipe.idReceta || currentRecipe.id)}>
                    {userInteractions.favoritos.has(currentRecipe.idReceta || currentRecipe.id)
                      ? <BookmarkIcon color="primary" />
                      : <BookmarkBorderIcon />
                    }
                  </IconButton>
                </Box>

                <Typography sx={{ mt: 2, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Ingredientes</Typography>
                <Box component="ul" sx={{ pl: 3, mt: 0.5, mb: 1 }}>
                  {(currentRecipe.ingredientes || []).slice(0, 3).map(i => (
                    <li key={i.idIngrediente || i.id}>{truncateText(i.nombre, 40)}</li>
                  ))}
                  {(currentRecipe.ingredientes || []).length > 3 && (
                    <li><em>... y {(currentRecipe.ingredientes || []).length - 3} más</em></li>
                  )}
                </Box>

                <Typography sx={{ mt: 1, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Preparación</Typography>
                <Typography sx={{ mt: 0.5, mb: 2, whiteSpace: 'pre-wrap' }}>
                  {truncateText(currentRecipe.preparacion || currentRecipe.descripcion || '', 120)}
                </Typography>

                {/* Botón Ver Receta Completa */}
                <Box sx={{ mt: 2, display: 'flex', justifyContent: 'center' }}>
                  <Button
                    variant="contained"
                    startIcon={<VisibilityIcon />}
                    onClick={() => handleOpenReceta(currentRecipe)}
                    sx={{
                      backgroundColor: '#99682E',
                      color: 'white',
                      fontFamily: 'Lato, sans-serif',
                      fontWeight: 700,
                      px: 4,
                      py: 1,
                      '&:hover': {
                        backgroundColor: '#7a5424'
                      }
                    }}
                  >
                    Ver Receta
                  </Button>
                </Box>
              </>
            ) : (
              <Typography>Cargando recetas...</Typography>
            )}
          </Box>
          <Box sx={{ flex: '1 1 50%', display: 'flex', justifyContent: 'center', alignItems: 'flex-start' }}>
            {currentRecipe ? (
              <Box 
                component="img" 
                src={currentRecipe.urlImagen || 'https://placehold.co/624x352?text=No+Image'} 
                alt={currentRecipe.nombre} 
                sx={{ 
                  width: '100%', 
                  maxWidth: 624, 
                  height: 352, 
                  objectFit: 'cover', 
                  borderRadius: 2 
                }} 
                id="recetaDelDiaImg" 
                onError={(e)=>{ e.target.src='https://placehold.co/624x352?text=No+Image'; }} 
              />
            ) : (
              <Box 
                component="img" 
                src="https://placehold.co/624x352?text=No+Image" 
                alt="placeholder" 
                sx={{ 
                  width: '100%', 
                  maxWidth: 624, 
                  height: 352, 
                  objectFit: 'cover', 
                  borderRadius: 2 
                }} 
              />
            )}
          </Box>
        </Box>
      </Container>

      {/* Modal de receta */}
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
            <IconButton aria-label="fav" onClick={() => handleFavorite(selectedReceta?.idReceta || selectedReceta?.id)}>
              {userInteractions.favoritos.has(selectedReceta?.idReceta || selectedReceta?.id) ? <BookmarkIcon color="error" /> : <BookmarkBorderIcon />}
            </IconButton>
          </Box>
          
          <Typography sx={{ fontWeight: 700, mt: 2 }}>Comentarios</Typography>
          <List>
            {(comentarios || []).map(c => (
              <ListItem key={c.idComentario || c.id}><ListItemText primary={c.nombreUsuario || 'Usuario'} secondary={c.texto || c.comentario} /></ListItem>
            ))}
          </List>
          <Box sx={{ display: 'flex', gap: 1, mt: 1 }}>
            <TextField 
              size="small" 
              fullWidth 
              placeholder="Escribe un comentario..." 
              value={newComentario} 
              onChange={(e)=> setNewComentario(e.target.value)} 
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
            >
              Enviar
            </Button>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseReceta}>Cerrar</Button>
        </DialogActions>
      </Dialog>

      {/* Diálogos auxiliares */}
      <AuthPromptDialog open={authPromptOpen} onClose={()=> setAuthPromptOpen(false)} />
      <RatingDialog 
        open={ratingDialogOpen} 
        onClose={() => setRatingDialogOpen(false)} 
        onRate={handleRate}
        onDelete={handleDeleteRating}
        recetaNombre={ratingRecetaNombre}
        hasRating={userInteractions.estrellas.has(ratingRecetaId)}
      />
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
