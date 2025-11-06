import axios from 'axios';

// Utilidad para verificar si una respuesta de la API indica error
export const checkApiResponse = (response) => {
  if (response?.data?.exito === false) {
    throw new Error(response.data?.mensaje || 'Error en la operación');
  }
  return response;
};

// Utilidad para formatear fechas de YYYY-MM-DD a DD-MM-YYYY
export const formatFecha = (fecha) => {
  if (!fecha) return '';
  
  try {
    // Si la fecha ya está en formato DD-MM-YYYY, retornarla tal cual
    if (typeof fecha === 'string' && /^\d{2}-\d{2}-\d{4}$/.test(fecha)) {
      return fecha;
    }
    
    // Convertir a objeto Date
    const date = new Date(fecha);
    
    // Verificar si la fecha es válida
    if (isNaN(date.getTime())) return fecha;
    
    // Formatear a DD-MM-YYYY
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    
    return `${day}-${month}-${year}`;
  } catch (e) {
    return fecha;
  }
};

// Use proxy in development (package.json has proxy config)
// In production, use full URL
const API_BASE = process.env.NODE_ENV === 'production' 
  ? 'http://168.181.187.137:8081' 
  : ''; // Empty string uses proxy from package.json

const api = axios.create({
  baseURL: API_BASE,
  timeout: 10000,
  withCredentials: false,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

// Attach Authorization header automatically if authToken exists
api.interceptors.request.use((config) => {
  try {
    const token = localStorage.getItem('authToken');
    if (token && token !== 'null' && token !== 'undefined' && token.toString().trim() !== '') {
      config.headers = config.headers || {};
      config.headers['Authorization'] = `Bearer ${token}`;
    }
  } catch (e) {}
  return config;
}, (err) => Promise.reject(err));

// Response interceptor to unwrap backend's wrapped response format: { data: [...], exito: true, mensaje: "..." }
api.interceptors.response.use((response) => {
  // If backend returns { data: [...], exito: true }, extract the data field
  if (response.data && typeof response.data === 'object') {
    if ('data' in response.data && 'exito' in response.data) {
      // Unwrap: replace response.data with response.data.data
      response.data = response.data.data;
    }
  }
  return response;
}, (err) => {
  // Detectar token expirado o inválido
  if (err.response) {
    const { status, data } = err.response;
    
    // Verificar si es un error de autenticación
    const isAuthError = status === 401 || status === 403;
    const hasTokenError = data && (
      (typeof data === 'object' && data.error && 
        (data.error.toLowerCase().includes('token') || 
         data.error.toLowerCase().includes('expired') ||
         data.error.toLowerCase().includes('invalid'))) ||
      (typeof data === 'string' && 
        (data.toLowerCase().includes('token') || 
         data.toLowerCase().includes('expired')))
    );
    
    // Si es error de autenticación, cerrar sesión
    if (isAuthError || hasTokenError) {
      console.warn('⚠️ Sesión expirada o token inválido. Cerrando sesión...');
      
      // Limpiar localStorage
      localStorage.removeItem('authToken');
      localStorage.removeItem('user');
      
      // Redirigir al login
      window.location.href = '/login';
    }
  }
  
  return Promise.reject(err);
});

// Recetas
export const getRecetas = () => api.get('/recetas');
export const getReceta = (id) => api.get(`/recetas/${id}`);
export const postReceta = (data) => api.post('/recetas', data);
export const putReceta = (id, data) => api.put(`/recetas/${id}`, data);
export const deleteReceta = (id) => api.delete(`/recetas/${id}`);
export const getRecetasTrending = (limit) => api.get(`/recetas/trending${limit ? `?limit=${limit}` : ''}`);
export const getRecetaDelDia = () => api.get('/recetas/del-dia');
export const getRecetasByPais = (idPais) => api.get(`/recetas/pais/${idPais}`);
export const getRecetasByCategoria = (idCat) => api.get(`/recetas/categoria/${idCat}`);
export const searchRecetasByNombre = (nombre) => api.get(`/recetas/nombre/${encodeURIComponent(nombre)}`);

// Helper to get recetas by usuario
export const getRecetasByUsuario = async (userId) => {
  if (!userId) return Promise.resolve({ data: [] });
  try {
    return await api.get(`/recetas/usuario/${userId}`);
  } catch (e) {
    const r = await api.get('/recetas');
    const data = r && r.data ? r.data : r;
    const list = Array.isArray(data) ? data : (data?.recetas || data?.items || []);
    const filtered = list.filter(item => {
      const uid = item.idUsr || item.idUsuario || item.createdBy || item.autorId || item.userId;
      return uid && String(uid) === String(userId);
    });
    return { data: filtered };
  }
};

// Usuarios / Auth
export const getUsuarios = () => api.get('/usuarios');
export const getUsuario = (id) => api.get(`/usuarios/${id}`);
export const postUsuario = (data) => api.post('/usuarios', data);
export const login = (credentials) => api.post('/auth/login', credentials);
export const register = (userData) => api.post('/auth/register', userData);

// Paises
export const getPaises = () => api.get('/paises');
export const getPais = (id) => api.get(`/paises/${id}`);

// Categorias
export const getCategorias = () => api.get('/categorias');
export const getCategoria = (id) => api.get(`/categorias/${id}`);

// Favoritos - using /recetas/favoritos for user context (requires query params idUsuario and idReceta)
export const getFavoritos = () => {
  const token = localStorage.getItem('authToken');
  return api.get('/recetas/favoritos', {
    headers: { Authorization: `Bearer ${token}` }
  });
};

export const getMeGustas = () => {
  const token = localStorage.getItem('authToken');
  return api.get('/recetas/megusta', {
    headers: { Authorization: `Bearer ${token}` }
  });
};

export const getEstrellas = () => {
  const token = localStorage.getItem('authToken');
  return api.get('/recetas/estrellas', {
    headers: { Authorization: `Bearer ${token}` }
  });
};

export const postFavoritoReceta = (recetaId) => {
  const token = localStorage.getItem('authToken');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const userId = user.id_usr || user.idUsr || user.id;
  return api.post(`/recetas/favoritos?idUsuario=${userId}&idReceta=${recetaId}`, null, {
    headers: { Authorization: `Bearer ${token}` }
  });
};

export const deleteFavoritoReceta = (recetaId) => {
  const token = localStorage.getItem('authToken');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const userId = user.id_usr || user.idUsr || user.id;
  return api.delete(`/recetas/favoritos?idUsuario=${userId}&idReceta=${recetaId}`, {
    headers: { Authorization: `Bearer ${token}` }
  });
};

// Me Gusta - using /recetas/megusta (requires query params idUsuario and idReceta)
export const postLikeReceta = (recetaId) => {
  const token = localStorage.getItem('authToken');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const userId = user.id_usr || user.idUsr || user.id;
  return api.post(`/recetas/megusta?idUsuario=${userId}&idReceta=${recetaId}`, null, {
    headers: { Authorization: `Bearer ${token}` }
  });
};

export const deleteLikeReceta = (recetaId) => {
  const token = localStorage.getItem('authToken');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const userId = user.id_usr || user.idUsr || user.id;
  return api.delete(`/recetas/megusta?idUsuario=${userId}&idReceta=${recetaId}`, {
    headers: { Authorization: `Bearer ${token}` }
  });
};

// Estrellas/Rating - using /recetas/estrellas (requires query params idUsuario, idReceta, and estrellas)
export const postStarReceta = (recetaId, valorEstrellas = 5) => {
  const token = localStorage.getItem('authToken');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const userId = user.id_usr || user.idUsr || user.id;
  return api.post(`/recetas/estrellas?idUsuario=${userId}&idReceta=${recetaId}&estrellas=${valorEstrellas}`, null, {
    headers: { Authorization: `Bearer ${token}` }
  });
};

export const deleteStarReceta = (estrellaId) => {
  const token = localStorage.getItem('authToken');
  return api.delete(`/recetas/estrellas/${estrellaId}`, {
    headers: { Authorization: `Bearer ${token}` }
  });
};

export const getEstrellaStats = (recetaId) => api.get(`/recetas/estrellas/stats/${recetaId}`);
export const getMeGustaCount = (recetaId) => api.get(`/recetas/megustas/count/${recetaId}`);

export const getComentariosReceta = (recetaId) => api.get(`/recetas/comentarios/receta/${recetaId}`);
export const postComentarioReceta = (recetaId, textoComentario) => {
  const token = localStorage.getItem('authToken');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const userId = user.id_usr || user.idUsr || user.id;
  const fechaCreacion = new Date().toISOString(); // ISO format para el backend
  
  // El backend espera SOLO query parameters (sin fechaCreacion por ahora - backend debe generarla)
  // Si el backend se actualiza para aceptar fechaCreacion, agregar: &fechaCreacion=${encodeURIComponent(fechaCreacion)}
  return api.post(`/recetas/comentarios?idUsuario=${userId}&idReceta=${recetaId}&texto=${encodeURIComponent(textoComentario)}&fechaCreacion=${encodeURIComponent(fechaCreacion)}`, null, {
    headers: { Authorization: `Bearer ${token}` }
  });
};

// Donaciones
export const createDonationSession = async (amount) => {
  const token = localStorage.getItem('authToken');
  if (!token) {
    throw new Error('Debes iniciar sesión para donar');
  }
  
  return api.post('/donaciones/create-session', { amount }, {
    headers: { Authorization: `Bearer ${token}` }
  });
};

// Usuarios
export const updateUsuario = async (userId, userData) => {
  const token = localStorage.getItem('authToken');
  if (!token) {
    throw new Error('Debes iniciar sesión para actualizar tus datos');
  }
  
  return api.put(`/usuarios/${userId}`, userData, {
    headers: { Authorization: `Bearer ${token}` }
  });
};

// Auth helper
export const isAuthenticated = () => {
  try {
    const token = localStorage.getItem('authToken');
    return !!(token && token !== 'null' && token !== 'undefined' && token.toString().trim() !== '');
  } catch (e) {
    return false;
  }
};

export const isAdmin = () => {
  try {
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    return user.rol === 'ADMIN';
  } catch (e) {
    return false;
  }
};

// ==================== ADMIN ENDPOINTS ====================

// Admin - Usuarios
export const adminGetUsuarios = () => api.get('/usuarios');
export const adminGetUsuario = (id) => api.get(`/usuarios/${id}`);
export const adminUpdateUsuario = (id, data) => api.put(`/usuarios/${id}`, data);
export const adminDeleteUsuario = (id) => api.delete(`/usuarios/${id}`);

// Admin - Recetas
export const adminGetRecetas = () => api.get('/recetas');
export const adminGetReceta = (id) => api.get(`/recetas/${id}`);
export const adminUpdateReceta = (id, data) => api.put(`/recetas/${id}`, data);
export const adminDeleteReceta = (id) => api.delete(`/recetas/${id}`);

// Admin - Países
export const adminGetPaises = () => api.get('/paises');
export const adminGetPais = (id) => api.get(`/paises/${id}`);
export const adminCreatePais = (data) => api.post('/paises', data);
export const adminUpdatePais = (id, data) => api.put(`/paises/${id}`, data);
export const adminDeletePais = (id) => api.delete(`/paises/${id}`);

// Admin - Categorías
export const adminGetCategorias = () => api.get('/categorias');
export const adminGetCategoria = (id) => api.get(`/categorias/${id}`);
export const adminCreateCategoria = (data) => api.post('/categorias', data);
export const adminUpdateCategoria = (id, data) => api.put(`/categorias/${id}`, data);
export const adminDeleteCategoria = (id) => api.delete(`/categorias/${id}`);

// Admin - Me Gusta
export const adminGetMeGustas = () => api.get('/admin/megusta');
export const adminGetMeGusta = (id) => api.get(`/admin/megusta/${id}`);
export const adminCreateMeGusta = (data) => api.post('/admin/megusta', data);
export const adminUpdateMeGusta = (id, data) => api.put(`/admin/megusta/${id}`, data);
export const adminDeleteMeGusta = (id) => api.delete(`/admin/megusta/${id}`);

// Admin - Favoritos
export const adminGetFavoritos = () => api.get('/admin/favoritos');
export const adminGetFavorito = (id) => api.get(`/admin/favoritos/${id}`);
export const adminCreateFavorito = (data) => api.post('/admin/favoritos', data);
export const adminUpdateFavorito = (id, data) => api.put(`/admin/favoritos/${id}`, data);
export const adminDeleteFavorito = (id) => api.delete(`/admin/favoritos/${id}`);

// Admin - Estrellas
export const adminGetEstrellas = () => api.get('/admin/estrellas');
export const adminGetEstrella = (id) => api.get(`/admin/estrellas/${id}`);
export const adminCreateEstrella = (data) => api.post('/admin/estrellas', data);
export const adminUpdateEstrella = (id, data) => api.put(`/admin/estrellas/${id}`, data);
export const adminDeleteEstrella = (id) => api.delete(`/admin/estrellas/${id}`);

// Admin - Comentarios
export const adminGetComentarios = () => api.get('/admin/comentarios');
export const adminGetComentario = (id) => api.get(`/admin/comentarios/${id}`);
export const adminCreateComentario = (data) => api.post('/admin/comentarios', data);
export const adminUpdateComentario = (id, data) => api.put(`/admin/comentarios/${id}`, data);
export const adminDeleteComentario = (id) => api.delete(`/admin/comentarios/${id}`);

// Admin - Ingredientes
export const adminGetIngredientes = () => api.get('/admin/ingredientes');
export const adminGetIngrediente = (id) => api.get(`/admin/ingredientes/${id}`);
export const adminCreateIngrediente = (data) => api.post('/admin/ingredientes', data);
export const adminUpdateIngrediente = (id, data) => api.put(`/admin/ingredientes/${id}`, data);
export const adminDeleteIngrediente = (id) => api.delete(`/admin/ingredientes/${id}`);

export default api;
