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
import { useEffect, useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import AuthPromptDialog from './AuthPromptDialog';
import RatingDialog from './RatingDialog';
import $ from 'jquery';
import 'owl.carousel/dist/assets/owl.carousel.css';
import 'owl.carousel/dist/assets/owl.theme.default.css';
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
  isAdmin,
  getComentariosReceta,
  postComentarioReceta,
  getUserNombre,
  formatFecha
} from '../api';
import { Link as RouterLink } from 'react-router-dom';

// Hacer jQuery disponible globalmente para owl.carousel
window.jQuery = window.$ = $;

// Importar owl.carousel después de configurar jQuery globalmente
require('owl.carousel');export default function Home(){
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
      getRecetasTrending(1).catch(()=>({ data: [] })),
      getRecetaDelDia().catch(()=>null)
    ]).then(([trendingRes, recetaDelDiaRes]) => {
      const trendingData = trendingRes && trendingRes.data ? trendingRes.data : trendingRes;
      const trendingList = Array.isArray(trendingData) ? trendingData : (Array.isArray(trendingData?.recetas) ? trendingData.recetas : (Array.isArray(trendingData?.items) ? trendingData.items : []));
      
      const recetaDelDiaData = recetaDelDiaRes && recetaDelDiaRes.data ? recetaDelDiaRes.data : recetaDelDiaRes;
      const recetaDelDia = Array.isArray(recetaDelDiaData) ? recetaDelDiaData[0] : recetaDelDiaData;
      
      const recipes = [];
      if(recetaDelDia) recipes.push({ ...recetaDelDia, isRecetaDelDia: true });
      
      // Seleccionar la mejor receta trending (ahora solo 1)
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
      <Box sx={{ 
        background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)', 
        py: { xs: 4, sm: 6, md: 8 },
        position: 'relative',
        overflow: 'hidden',
        '&::before': {
          content: '""',
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundImage: `url('/img/fondo_inicio.jpg')`,
          backgroundRepeat: 'repeat',
          backgroundSize: '150px',
          opacity: 0.08,
          zIndex: 0
        }
      }}>
        <Container sx={{ display: 'flex', alignItems: 'center', gap: { xs: 2, md: 4 }, flexWrap: { xs: 'wrap', md: 'nowrap' }, position: 'relative', zIndex: 1 }}>
          <Box sx={{ flex: '1 1 100%', textAlign: { xs: 'center', md: 'left' } }}>
            <Typography 
              variant="h3" 
              component="h1" 
              sx={{ 
                color: '#FFFFFF', 
                fontFamily: 'Roboto, sans-serif', 
                fontWeight: 900,
                mb: 2,
                fontSize: { xs: '2rem', sm: '2.5rem', md: '3rem' },
                textShadow: '2px 2px 4px rgba(0,0,0,0.2)'
              }}
            >
              Bienvenid@
            </Typography>
            <Typography sx={{ 
              color: '#FFFFFF', 
              fontFamily: 'Open Sans, sans-serif', 
              fontWeight: 600,
              fontSize: { xs: '0.95rem', sm: '1rem', md: '1.1rem' },
              lineHeight: 1.6,
              textShadow: '1px 1px 2px rgba(0,0,0,0.1)',
              maxWidth: { xs: '100%', md: '500px' }
            }}>
              ¡Bienvenido a nuestra pagina de comidas! Aquí podrás descubrir deliciosas opciones de diferentes países para satisfacer tus antojos culinarios. ¡Buen provecho!
            </Typography>
          </Box>
          <Box sx={{ flex: { xs: '0 0 100%', md: '0 0 420px' }, display: { xs: 'none', sm: 'flex' }, justifyContent: 'center' }}>
            <Box 
              component="img" 
              src="/img/cheems-waso.png" 
              alt="" 
              sx={{ 
                width: '100%', 
                maxWidth: { xs: 280, sm: 350, md: 420 },
                filter: 'drop-shadow(4px 4px 8px rgba(0,0,0,0.2))'
              }} 
            />
          </Box>
        </Container>
      </Box>

      {/* Como funciona */}
      <Box sx={{ backgroundColor: '#F7FAFC', py: { xs: 4, md: 6 } }}>
        <Container>
          <Stack spacing={4} alignItems="center">
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <CheckCircleIcon sx={{ color: '#667EEA', fontSize: { xs: 28, md: 32 } }} />
              <Typography variant="h4" sx={{ 
                color: '#1A202C', 
                fontFamily: 'Lato, sans-serif', 
                fontWeight: 900,
                fontSize: { xs: '1.5rem', sm: '2rem', md: '2.125rem' }
              }}>
                Cómo funciona
              </Typography>
              <CheckCircleIcon sx={{ color: '#667EEA', fontSize: { xs: 28, md: 32 } }} />
            </Box>

            <Box sx={{ display: 'flex', gap: { xs: 2, md: 4 }, flexWrap: 'wrap', justifyContent: 'center', width: '100%' }}>
              <Box sx={{ 
                textAlign: 'center', 
                flexBasis: { xs: '100%', sm: 'calc(50% - 16px)', md: '30%' },
                backgroundColor: 'white',
                borderRadius: 3,
                p: { xs: 2, md: 3 },
                boxShadow: '0 4px 12px rgba(102, 126, 234, 0.1)',
                transition: 'transform 0.3s ease, box-shadow 0.3s ease',
                '&:hover': {
                  transform: 'translateY(-8px)',
                  boxShadow: '0 8px 24px rgba(102, 126, 234, 0.2)'
                }
              }}>
                <Box component="img" src="/img/Eat-and-Enjoy-8.png" alt="acceso" sx={{ maxWidth: { xs: 100, md: 120 }, mb: 2 }} />
                <Typography variant="h6" sx={{ 
                  color: '#667EEA', 
                  fontFamily: 'Lato, sans-serif', 
                  fontWeight: 900, 
                  mb: 1,
                  fontSize: { xs: '1rem', md: '1.25rem' }
                }}>
                  ¿De donde puedes Acceder?
                </Typography>
                <Typography sx={{ 
                  color: '#718096', 
                  fontFamily: 'Open Sans, sans-serif', 
                  fontWeight: 400,
                  fontSize: { xs: '0.875rem', md: '1rem' }
                }}>
                  Desde todas las partes del mundo, sin importar donde seas
                </Typography>
              </Box>

              <Box sx={{ 
                textAlign: 'center', 
                flexBasis: { xs: '100%', sm: 'calc(50% - 16px)', md: '30%' },
                backgroundColor: 'white',
                borderRadius: 3,
                p: { xs: 2, md: 3 },
                boxShadow: '0 4px 12px rgba(102, 126, 234, 0.1)',
                transition: 'transform 0.3s ease, box-shadow 0.3s ease',
                '&:hover': {
                  transform: 'translateY(-8px)',
                  boxShadow: '0 8px 24px rgba(102, 126, 234, 0.2)'
                }
              }}>
                <Box component="img" src="/img/Meal-icon-8.png" alt="de-donde" sx={{ maxWidth: { xs: 100, md: 120 }, mb: 2 }} />
                <Typography variant="h6" sx={{ 
                  color: '#667EEA', 
                  fontFamily: 'Lato, sans-serif', 
                  fontWeight: 900, 
                  mb: 1,
                  fontSize: { xs: '1rem', md: '1.25rem' }
                }}>
                  ¿De donde?
                </Typography>
                <Typography sx={{ 
                  color: '#718096', 
                  fontFamily: 'Open Sans, sans-serif', 
                  fontWeight: 400,
                  fontSize: { xs: '0.875rem', md: '1rem' }
                }}>
                  Gracias a la gran comunidad culinaria, podemos traer recetas desde cualquier parte del mundo
                </Typography>
              </Box>

              <Box sx={{ 
                textAlign: 'center', 
                flexBasis: { xs: '100%', sm: 'calc(50% - 16px)', md: '30%' },
                backgroundColor: 'white',
                borderRadius: 3,
                p: { xs: 2, md: 3 },
                boxShadow: '0 4px 12px rgba(102, 126, 234, 0.1)',
                transition: 'transform 0.3s ease, box-shadow 0.3s ease',
                '&:hover': {
                  transform: 'translateY(-8px)',
                  boxShadow: '0 8px 24px rgba(102, 126, 234, 0.2)'
                }
              }}>
                <Box component="img" src="/img/Recurso-41-8.png" alt="ayuda" sx={{ maxWidth: { xs: 100, md: 120 }, mb: 2 }} />
                <Typography variant="h6" sx={{ 
                  color: '#667EEA', 
                  fontFamily: 'Lato, sans-serif', 
                  fontWeight: 900, 
                  mb: 1,
                  fontSize: { xs: '1rem', md: '1.25rem' }
                }}>
                  ¿Puedo Ayudar?
                </Typography>
                <Typography sx={{ 
                  color: '#718096', 
                  fontFamily: 'Open Sans, sans-serif', 
                  fontWeight: 400,
                  fontSize: { xs: '0.875rem', md: '1rem' }
                }}>
                  claro, solo necesitas acceder y podras aportar a esta gran comunidad
                </Typography>
              </Box>
            </Box>
          </Stack>
        </Container>
      </Box>

      {/* PAÍSES */}
      <Container maxWidth="xl" sx={{ py: { xs: 4, md: 6 }, maxWidth: '1400px' }}>
        <Box textAlign="center">
          <Box sx={{ display: 'flex', alignItems: 'center', gap: { xs: 1, md: 2 }, justifyContent: 'center', mb: { xs: 3, md: 4 } }}>
            <Box sx={{ display: { xs: 'none', sm: 'block' }, flex: '1 1 30%', maxWidth: 385, borderBottom: '3px solid rgba(102, 126, 234, 0.7)' }} />
            <CheckCircleIcon sx={{ color: '#667EEA', fontSize: { xs: 24, md: 32 } }} />
            <Typography variant="h4" sx={{ color: '#1A202C', fontFamily: 'Lato, sans-serif', fontWeight: 900, fontSize: { xs: '1.5rem', md: '2.125rem' } }}>PAÍSES</Typography>
            <CheckCircleIcon sx={{ color: '#667EEA', fontSize: { xs: 24, md: 32 } }} />
            <Box sx={{ display: { xs: 'none', sm: 'block' }, flex: '1 1 30%', maxWidth: 385, borderBottom: '3px solid rgba(102, 126, 234, 0.7)' }} />
          </Box>
          <Box sx={{ textAlign: 'center', mt: 3 }}>
            <PaisesPreview />
          </Box>
        </Box>
      </Container>

      {/* Divider between PAÍSES and RECETA TRENDING TOPIC */}
      <Container sx={{ py: 1 }}>
        <Box sx={{ display: 'flex', justifyContent: 'center', my: { xs: 1, md: 2 } }}>
          <Box sx={{ width: { xs: '95%', md: '88%' }, borderTop: '2px solid rgba(102, 126, 234, 0.85)', borderRadius: 1 }} />
        </Box>
      </Container>

      {/* RECETA TRENDING TOPIC / RECETA DEL DÍA - CAROUSEL */}
      <Container sx={{ py: { xs: 4, md: 6 } }}>
        <Box sx={{ 
          display: 'flex', 
          gap: { xs: 2, md: 4 }, 
          alignItems: 'flex-start', 
          flexWrap: { xs: 'wrap', md: 'nowrap' },
          backgroundColor: 'white',
          borderRadius: 3,
          p: { xs: 2, md: 4 },
          boxShadow: '0 4px 16px rgba(102, 126, 234, 0.15)'
        }}>
          <Box sx={{ flex: '1 1 100%', md: '1 1 50%' }}>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: { xs: 2, md: 3 }, flexWrap: 'wrap', gap: 1 }}>
              <Typography variant="h5" sx={{ 
                fontFamily: 'Lato, sans-serif', 
                fontWeight: 900, 
                color: '#1A202C',
                display: 'flex',
                alignItems: 'center',
                gap: 1,
                fontSize: { xs: '1.2rem', md: '1.5rem' }
              }}>
                {currentRecipe?.isRecetaDelDia && '🌟 '}
                {currentRecipe?.isRecetaDelDia ? 'Receta del Día' : 'Receta Trending Topic'}
              </Typography>
              <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                <IconButton 
                  onClick={handlePrevious} 
                  disabled={carouselRecipes.length === 0} 
                  size="small"
                  sx={{
                    background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
                    color: 'white',
                    '&:hover': {
                      background: 'linear-gradient(135deg, #764BA2 0%, #667EEA 100%)'
                    },
                    '&:disabled': {
                      backgroundColor: '#E2E8F0'
                    }
                  }}
                >
                  <ArrowBackIosNewIcon fontSize="small" />
                </IconButton>
                <Typography sx={{ fontWeight: 600, color: '#667EEA', minWidth: '50px', textAlign: 'center', fontSize: { xs: '0.875rem', md: '1rem' } }}>
                  {carouselRecipes.length > 0 ? `${currentIndex + 1}/${carouselRecipes.length}` : '0/0'}
                </Typography>
                <IconButton 
                  onClick={handleNext} 
                  disabled={carouselRecipes.length === 0} 
                  size="small"
                  sx={{
                    background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
                    color: 'white',
                    '&:hover': {
                      background: 'linear-gradient(135deg, #764BA2 0%, #667EEA 100%)'
                    },
                    '&:disabled': {
                      backgroundColor: '#E2E8F0'
                    }
                  }}
                >
                  <ArrowForwardIosIcon fontSize="small" />
                </IconButton>
              </Box>
            </Box>
            {currentRecipe ? (
              <>
                <Typography variant="h6" sx={{ fontFamily: 'Roboto, sans-serif', fontWeight: 900, color: '#1A202C', mb: 1, fontSize: { xs: '1rem', md: '1.25rem' } }} id="recetaDelDiaNombre">
                  {currentRecipe.nombre}
                </Typography>
                <Typography sx={{ mt: 1, color: '#718096', fontFamily: 'Open Sans, sans-serif', lineHeight: 1.6, fontSize: { xs: '0.875rem', md: '1rem' } }} id="recetaDelDiaDescripcion">
                  {truncateText(currentRecipe.descripcionCorta || currentRecipe.descripcion || '', 100)}
                </Typography>
                
                {/* Interactions and Statistics */}
                <Box sx={{ 
                  display: 'flex', 
                  justifyContent: 'space-between', 
                  alignItems: 'center', 
                  mt: { xs: 2, md: 3 }, 
                  mb: { xs: 2, md: 3 }, 
                  flexWrap: 'wrap', 
                  gap: 2,
                  backgroundColor: '#F7FAFC',
                  borderRadius: 2,
                  p: { xs: 1.5, md: 2 }
                }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: { xs: 1, md: 2 }, flexWrap: 'wrap' }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                      <IconButton 
                        onClick={() => handleLike(currentRecipe.idReceta || currentRecipe.id)} 
                        size="small"
                        sx={{
                          backgroundColor: userInteractions.likes.has(currentRecipe.idReceta || currentRecipe.id) ? '#4299E1' : 'white',
                          color: userInteractions.likes.has(currentRecipe.idReceta || currentRecipe.id) ? 'white' : '#4299E1',
                          '&:hover': {
                            backgroundColor: '#4299E1',
                            color: 'white'
                          }
                        }}
                      >
                        {userInteractions.likes.has(currentRecipe.idReceta || currentRecipe.id) 
                          ? <ThumbUpIcon fontSize="small" /> 
                          : <ThumbUpOutlinedIcon fontSize="small" />
                        }
                      </IconButton>
                      <Typography sx={{ fontWeight: 600, color: '#1A202C', fontSize: { xs: '0.875rem', md: '1rem' } }}>{recipeStats.likesCount}</Typography>
                    </Box>
                    
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                      <IconButton 
                        onClick={() => handleOpenRating(currentRecipe.idReceta || currentRecipe.id, currentRecipe.nombre)} 
                        size="small"
                        sx={{
                          backgroundColor: userInteractions.estrellas.has(currentRecipe.idReceta || currentRecipe.id) ? '#ED8936' : 'white',
                          color: userInteractions.estrellas.has(currentRecipe.idReceta || currentRecipe.id) ? 'white' : '#ED8936',
                          '&:hover': {
                            backgroundColor: '#ED8936',
                            color: 'white'
                          }
                        }}
                      >
                        {userInteractions.estrellas.has(currentRecipe.idReceta || currentRecipe.id) 
                          ? <StarIcon fontSize="small" /> 
                          : <StarOutlineIcon fontSize="small" />
                        }
                      </IconButton>
                      <Typography sx={{ fontWeight: 600, color: '#1A202C', fontSize: { xs: '0.875rem', md: '1rem' } }}>
                        {recipeStats.avgStars.toFixed(1)} 
                        <Typography component="span" sx={{ color: '#718096', fontSize: { xs: '0.75rem', md: '0.85rem' } }}>
                          ({recipeStats.totalStars})
                        </Typography>
                      </Typography>
                    </Box>
                  </Box>
                  
                  <IconButton 
                    onClick={() => handleFavorite(currentRecipe.idReceta || currentRecipe.id)}
                    sx={{
                      backgroundColor: userInteractions.favoritos.has(currentRecipe.idReceta || currentRecipe.id) ? '#F56565' : 'white',
                      color: userInteractions.favoritos.has(currentRecipe.idReceta || currentRecipe.id) ? 'white' : '#F56565',
                      '&:hover': {
                        backgroundColor: '#F56565',
                        color: 'white'
                      }
                    }}
                  >
                    {userInteractions.favoritos.has(currentRecipe.idReceta || currentRecipe.id)
                      ? <BookmarkIcon />
                      : <BookmarkBorderIcon />
                    }
                  </IconButton>
                </Box>

                <Typography sx={{ mt: { xs: 1.5, md: 2 }, fontFamily: 'Roboto, sans-serif', fontWeight: 900, color: '#1A202C', fontSize: { xs: '0.95rem', md: '1rem' } }}>Ingredientes</Typography>
                <Box component="ul" sx={{ pl: 3, mt: 1, mb: 2, color: '#718096', fontSize: { xs: '0.875rem', md: '1rem' } }}>
                  {(currentRecipe.ingredientes || []).slice(0, 3).map(i => (
                    <li key={i.idIngrediente || i.id}>{truncateText(i.nombre, 40)}</li>
                  ))}
                  {(currentRecipe.ingredientes || []).length > 3 && (
                    <li><em>... y {(currentRecipe.ingredientes || []).length - 3} más</em></li>
                  )}
                </Box>

                <Typography sx={{ mt: { xs: 1.5, md: 2 }, fontFamily: 'Roboto, sans-serif', fontWeight: 900, color: '#1A202C', fontSize: { xs: '0.95rem', md: '1rem' } }}>Preparación</Typography>
                <Typography sx={{ mt: 1, mb: 2, whiteSpace: 'pre-wrap', color: '#718096', fontFamily: 'Open Sans, sans-serif', fontSize: { xs: '0.875rem', md: '1rem' } }}>
                  {truncateText(currentRecipe.preparacion || currentRecipe.descripcion || '', 120)}
                </Typography>

                {/* Botón Ver Receta Completa */}
                <Box sx={{ mt: { xs: 2, md: 3 }, display: 'flex', justifyContent: 'center' }}>
                  <Button
                    variant="contained"
                    startIcon={<VisibilityIcon />}
                    onClick={() => handleOpenReceta(currentRecipe)}
                    sx={{
                      background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
                      color: 'white',
                      fontFamily: 'Roboto, sans-serif',
                      fontWeight: 700,
                      px: { xs: 3, md: 5 },
                      py: { xs: 1, md: 1.5 },
                      borderRadius: 50,
                      boxShadow: '0 4px 12px rgba(240, 147, 251, 0.3)',
                      fontSize: { xs: '0.875rem', md: '1rem' },
                      '&:hover': {
                        background: 'linear-gradient(135deg, #F5576C 0%, #F093FB 100%)',
                        boxShadow: '0 6px 16px rgba(240, 147, 251, 0.4)'
                      }
                    }}
                  >
                    Ver Receta Completa
                  </Button>
                </Box>
              </>
            ) : (
              <Typography>Cargando recetas...</Typography>
            )}
          </Box>
          <Box sx={{ flex: '1 1 100%', md: '1 1 50%', display: { xs: 'none', md: 'flex' }, justifyContent: 'center', alignItems: 'flex-start' }}>
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
                  borderRadius: 3,
                  boxShadow: '0 4px 16px rgba(102, 126, 234, 0.2)'
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
                  borderRadius: 3 
                }} 
              />
            )}
          </Box>
        </Box>
      </Container>

      {/* Modal de receta */}
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
            <Typography component="span" sx={{ 
              ml: 2, 
              fontSize: '0.9rem', 
              color: '#718096',
              fontWeight: 400
            }}>
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
            {(selectedReceta?.ingredientes || []).map(ingrediente => 
              ingrediente.nombre.split('\n').filter(line => line.trim()).map((line, idx) => (
                <Box 
                  component="li" 
                  key={`${ingrediente.idIngrediente}-${idx}`} 
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
              ))
            )}
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
                  onClick={() => handleOpenRating(selectedReceta?.idReceta || selectedReceta?.id, selectedReceta?.nombre)}
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
              onClick={() => handleFavorite(selectedReceta?.idReceta || selectedReceta?.id)}
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
          {comentarios.length === 0 ? (
            <Typography sx={{ 
              color: '#718096',
              fontFamily: 'Open Sans, sans-serif',
              textAlign: 'center',
              py: 3,
              mb: 2
            }}>
              No hay comentarios aún. ¡Sé el primero en comentar!
            </Typography>
          ) : (
            <List sx={{ mt: 1, mb: 2 }}>
              {(comentarios || []).map(c => (
                <ListItem 
                  key={c.idComentario || c.id}
                  sx={{
                    backgroundColor: '#F9E9AE',
                    borderRadius: 2,
                    mb: 1.5,
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
  const carouselRef = useRef(null);

  useEffect(()=>{
    getPaises().then(r=> setPaises(Array.isArray(r.data)? r.data.slice(0,12) : [])).catch(()=>{});
  },[]);

  useEffect(() => {
    if (paises.length > 0 && carouselRef.current) {
      const $carousel = $(carouselRef.current);
      
      // Destruir carrusel anterior si existe
      if ($carousel.hasClass('owl-loaded')) {
        $carousel.trigger('destroy.owl.carousel');
      }

      // Inicializar OwlCarousel
      $carousel.owlCarousel({
        loop: true,
        margin: 8,
        nav: true,
        navText: [
          '<svg viewBox="0 0 24 24" width="24" height="24"><path fill="currentColor" d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"/></svg>',
          '<svg viewBox="0 0 24 24" width="24" height="24"><path fill="currentColor" d="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z"/></svg>'
        ],
        dots: true,
        autoplay: true,
        autoplayTimeout: 5000,
        autoplayHoverPause: true,
        responsive: {
          0: {
            items: 1,
            nav: true
          },
          600: {
            items: 2,
            nav: true
          },
          1000: {
            items: 3,
            nav: true
          }
        }
      });

      // Cleanup
      return () => {
        if ($carousel.hasClass('owl-loaded')) {
          $carousel.trigger('destroy.owl.carousel');
        }
      };
    }
  }, [paises]);

  if (paises.length === 0) {
    return (
      <Box sx={{ 
        textAlign: 'center', 
        py: 8,
        color: '#718096',
        fontFamily: 'Open Sans, sans-serif'
      }}>
        No hay países disponibles
      </Box>
    );
  }

  return (
    <Box sx={{ 
      position: 'relative',
      width: '100%',
      '& .owl-carousel': {
        position: 'relative'
      },
      '& .owl-item': {
        backgroundColor: 'transparent !important',
        display: 'flex !important',
        alignItems: 'center !important',
        justifyContent: 'center !important'
      },
      '& .owl-item img': {
        width: '264px !important',
        height: '198px !important',
        maxWidth: '264px !important',
        maxHeight: '198px !important',
        objectFit: 'fill !important',
        borderRadius: '12px !important',
        boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1) !important',
        backgroundColor: 'white !important',
        '@media (min-width: 600px)': {
          width: '317px !important',
          height: '238px !important',
          maxWidth: '317px !important',
          maxHeight: '238px !important'
        },
        '@media (min-width: 1000px)': {
          width: '370px !important',
          height: '277px !important',
          maxWidth: '370px !important',
          maxHeight: '277px !important'
        }
      },
      '& .owl-nav': {
        position: 'absolute',
        top: '50%',
        transform: 'translateY(-50%)',
        width: '100%',
        display: 'flex',
        justifyContent: 'space-between',
        pointerEvents: 'none',
        zIndex: 10,
        margin: 0
      },
      '& .owl-nav button': {
        pointerEvents: 'auto',
        background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%) !important',
        color: 'white !important',
        width: '50px !important',
        height: '50px !important',
        borderRadius: '50% !important',
        display: 'flex !important',
        alignItems: 'center !important',
        justifyContent: 'center !important',
        transition: 'all 0.3s ease !important',
        border: 'none !important',
        boxShadow: '0 4px 12px rgba(102, 126, 234, 0.4) !important',
        fontSize: '0 !important',
        margin: '0 !important',
        '&:hover': {
          background: 'linear-gradient(135deg, #764BA2 0%, #667EEA 100%) !important',
          transform: 'scale(1.15) !important'
        },
        '& svg': {
          width: '24px !important',
          height: '24px !important'
        }
      },
      '& .owl-prev': {
        left: { xs: '-5px', md: '0px' },
        position: 'relative !important'
      },
      '& .owl-next': {
        right: { xs: '-5px', md: '0px' },
        position: 'relative !important'
      },
      '& .owl-dots': {
        textAlign: 'center',
        marginTop: '24px !important'
      },
      '& .owl-dot': {
        display: 'inline-block !important',
        margin: '0 4px !important'
      },
      '& .owl-dot span': {
        width: '10px !important',
        height: '10px !important',
        borderRadius: '50% !important',
        backgroundColor: 'rgba(102, 126, 234, 0.3) !important',
        display: 'block !important',
        transition: 'all 0.3s ease !important',
        cursor: 'pointer !important',
        margin: '0 !important',
        '&:hover': {
          backgroundColor: '#667EEA !important',
          transform: 'scale(1.3) !important'
        }
      },
      '& .owl-dot.active span': {
        backgroundColor: '#667EEA !important'
      },
      '& .owl-stage-outer': {
        overflow: 'hidden'
      },
      '& .owl-item': {
        backgroundColor: 'transparent !important'
      },
      '& .owl-stage': {
        backgroundColor: 'transparent !important'
      }
    }}>
      <div className="owl-carousel owl-theme" ref={carouselRef}>
        {paises.map((pais) => (
          <Box
            key={pais.idPais}
            component={RouterLink}
            to={`/paises/${pais.idPais}`}
            sx={{
              position: 'relative',
              height: { xs: 260, sm: 320, md: 380 },
              width: '100%',
              cursor: 'pointer',
              textDecoration: 'none',
              display: 'flex !important',
              alignItems: 'center',
              justifyContent: 'center',
              transition: 'all 0.4s ease',
              backgroundColor: 'transparent !important',
              '&:hover': {
                transform: 'scale(1.03)'
              }
            }}
          >
            {/* Imagen con tamaño fijo normalizado */}
            <Box
              component="img"
              src={pais.urlImagen || 'https://placehold.co/1200x600?text=No+Image'}
              alt={pais.nombre}
              sx={{
                width: { xs: '264px', sm: '317px', md: '370px' },
                height: { xs: '198px', sm: '238px', md: '277px' },
                objectFit: 'fill',
                backgroundColor: 'white',
                borderRadius: '12px',
                boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)',
                transition: 'transform 0.4s ease'
              }}
            />

            {/* Contenido - Nombre del país */}
            <Box sx={{
              position: 'absolute',
              bottom: 0,
              left: 0,
              right: 0,
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              pb: 3,
              px: 2,
              pointerEvents: 'none'
            }}>
              <Box
                sx={{
                  backgroundColor: 'rgba(102, 126, 234, 0.95)',
                  backdropFilter: 'blur(10px)',
                  borderRadius: 50,
                  px: { xs: 2, md: 3 },
                  py: { xs: 1, md: 1.5 },
                  boxShadow: '0 4px 16px rgba(102, 126, 234, 0.4)',
                  transition: 'all 0.3s ease',
                  pointerEvents: 'auto'
                }}
              >
                <Typography
                  sx={{
                    color: 'white',
                    fontFamily: 'Lato, sans-serif',
                    fontWeight: 900,
                    fontSize: { xs: '1.3rem', sm: '1.6rem', md: '2rem' },
                    textAlign: 'center',
                    textShadow: '0 2px 8px rgba(0, 0, 0, 0.3)'
                  }}
                >
                  {pais.nombre}
                </Typography>
              </Box>
            </Box>
          </Box>
        ))}
      </div>
    </Box>
  );
}
