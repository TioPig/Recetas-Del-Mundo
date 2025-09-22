import axios from 'axios';

const API_BASE = 'http://168.181.187.137:8081';

const api = axios.create({
  baseURL: API_BASE,
  timeout: 10000,
});

// Attach Authorization header automatically if authToken exists
api.interceptors.request.use((config) => {
  try{
    const token = localStorage.getItem('authToken');
    if(token && token !== 'null' && token !== 'undefined' && token.toString().trim() !== ''){
      // Avoid sending Authorization header on simple GET requests to public endpoints
      // (some backends reject CORS preflight when Authorization is present)
      const method = (config.method || '').toLowerCase();
      if(method && method === 'get'){
        // do not attach token for GET by default
      }else{
        config.headers = config.headers || {};
        config.headers['Authorization'] = `Bearer ${token}`;
      }
    }
  }catch(e){}
  return config;
}, (err) => Promise.reject(err));

// Recetas
export const getRecetas = () => api.get('/recetas/');
export const getReceta = (id) => api.get(`/recetas/${id}`);
export const postReceta = (data) => api.post('/recetas/', data);
export const putReceta = (id, data) => api.put(`/recetas/${id}`, data);
export const deleteReceta = (id) => api.delete(`/recetas/${id}`);
export const getRecetasTrending = (limit) => api.get(`/recetas/trending${limit? `?limit=${limit}` : ''}`);
export const getRecetasByPais = (idPais) => api.get(`/recetas/pais/${idPais}`);
export const getRecetasByCategoria = (idCat) => api.get(`/recetas/categoria/${idCat}`);
export const searchRecetasByNombre = (nombre) => api.get(`/recetas/nombre/${encodeURIComponent(nombre)}`);

// Helper to get recetas by usuario. Try endpoint first, otherwise fall back to client-side filter.
export const getRecetasByUsuario = async (userId) => {
  if(!userId) return Promise.resolve({ data: [] });
  try{
    return await api.get(`/recetas/usuario/${userId}`);
  }catch(e){
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
export const getUsuarios = () => api.get('/api/usuarios/');
export const getUsuario = (id) => api.get(`/api/usuarios/${id}`);
export const postUsuario = (data) => api.post('/api/usuarios', data);
// Some backends expose /api/login or /api/usuarios/login — provide both helpers
export const login = (credentials) => api.post('/api/login', credentials);
export const loginUsuario = (credentials) => api.post('/api/usuarios/login', credentials);

// Paises
export const getPaises = () => api.get('/paises/');
export const getPais = (id) => api.get(`/paises/${id}`);

// Categorias
export const getCategorias = () => api.get('/categorias/');
export const getCategoria = (id) => api.get(`/categorias/${id}`);

// Favoritos / Me gustas / Comentarios (ejemplos)
// According to Api.txt the favorites endpoints live under `/usuarios/favoritos` (no /api prefix)
export const getFavoritos = () => api.get('/usuarios/favoritos');
export const postFavorito = (data) => api.post('/usuarios/favoritos', data);
export const deleteFavorito = (data) => api.delete('/usuarios/favoritos', { data });

// Likes / Stars / Comentarios por receta
export const postLikeReceta = (recetaId, data = {}) => api.post(`/recetas/${recetaId}/likes`, data);
export const postStarReceta = (recetaId, data = {}) => api.post(`/recetas/${recetaId}/stars`, data);
export const postFavoritoReceta = (recetaId, data = {}) => api.post(`/recetas/${recetaId}/favorito`, data);

export const getComentariosReceta = (recetaId) => api.get(`/comentarios/receta/${recetaId}`);
export const postComentarioReceta = (recetaId, comentario) => api.post(`/comentarios/receta/${recetaId}`, comentario);

// Auth helper (simple local-storage based check)
export const isAuthenticated = () => {
  try{
    const token = localStorage.getItem('authToken');
    const userRaw = localStorage.getItem('user');

    // debug logging to track why auth decisions are made
    try{
      // eslint-disable-next-line no-console
      console.debug('isAuthenticated check -> token:', token, 'userRaw:', userRaw);
    }catch(e){}

    if(token && token !== 'null' && token !== 'undefined' && token.toString().trim() !== ''){
      // eslint-disable-next-line no-console
      console.debug('isAuthenticated -> true (token present)');
      return true;
    }

    if(!userRaw || userRaw === 'null' || userRaw === 'undefined' || userRaw.toString().trim() === ''){
      // eslint-disable-next-line no-console
      console.debug('isAuthenticated -> false (no userRaw)');
      return false;
    }

    // try to parse JSON user, fall back to truthy string
    try{
      const user = JSON.parse(userRaw);
      const ok = !!(user && (user.id || user._id || user.username || user.email));
      // eslint-disable-next-line no-console
      console.debug('isAuthenticated -> parsed user ok:', ok, user);
      return ok;
    }catch(e){
      // if it's a plain non-empty string (e.g. username) treat as authenticated
      // eslint-disable-next-line no-console
      console.debug('isAuthenticated -> true (userRaw non-empty string)');
      return true;
    }
  }catch(e){ return false; }
};

// Debug helper to inspect localStorage auth values from the app console
export const debugAuth = () => {
  try{
    const token = localStorage.getItem('authToken');
    const userRaw = localStorage.getItem('user');
    // log minimal info to avoid leaking sensitive data
    // (developer will see values in console while debugging)
    // eslint-disable-next-line no-console
    console.log('debugAuth -> token:', token, 'user:', userRaw, 'isAuthenticated:', isAuthenticated());
    // if we can parse a user id, try to fetch user details from backend
    try{
      if(userRaw){
        const parsed = JSON.parse(userRaw);
        const id = parsed && (parsed.id || parsed._id || parsed.idUsuario);
        if(id){
          // eslint-disable-next-line no-console
          console.log('debugAuth -> fetching user from API /api/usuarios/' + id);
          api.get(`/api/usuarios/${id}`).then(r => {
            // eslint-disable-next-line no-console
            console.log('debugAuth -> user fetch result:', r && r.data ? r.data : r);
          }).catch(err => {
            // eslint-disable-next-line no-console
            console.warn('debugAuth -> user fetch error:', err && err.message ? err.message : err);
          });
        }
      }
    }catch(e){ /* ignore parse errors */ }
    return isAuthenticated();
  }catch(e){ return false; }
};

export const setAuthToken = (token) => {
  try{
    if(token){
      localStorage.setItem('authToken', token);
      api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    }else{
      localStorage.removeItem('authToken');
      delete api.defaults.headers.common['Authorization'];
    }
  }catch(e){}
};

export default api;
