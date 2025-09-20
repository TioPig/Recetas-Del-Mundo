import React from 'react';
import { useState } from 'react';
import { useNavigate, Link as RouterLink } from 'react-router-dom';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import InputAdornment from '@mui/material/InputAdornment';
import IconButton from '@mui/material/IconButton';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import { loginUsuario, login } from '../api';
import Link from '@mui/material/Link';

export default function Login(){
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleSubmit = async () => {
    setError(null);
  if(!email || !password){ setError('Completa email y contraseña'); return; }
    setLoading(true);
    try{
      // try /api/usuarios/login first then fallback to /api/login
      let res = null;
  try{ res = await loginUsuario({ email, password }); }catch(e){ /* fallback below */ }
  if(!res){ res = await login({ email, password }); }

      const data = res && res.data ? res.data : res;
      // attempt to extract token and user from common shapes
      const token = data?.token || data?.authToken || data?.accessToken || data?.tokenJWT || data?.token_jwt;
      const user = data?.user || data?.usuario || data?.usuarioLogueado || data;

      if(token) localStorage.setItem('authToken', token);
      try{ localStorage.setItem('user', typeof user === 'string' ? user : JSON.stringify(user)); }catch(e){ /* ignore */ }

      setLoading(false);
      // navigate home
      navigate('/');
    }catch(e){
      setLoading(false);
      setError('Credenciales inválidas o error de conexión');
    }
  };

  return (
    <Box>
      <Box sx={{ textAlign: 'center', backgroundColor: '#F9E9AE', py: 4 }}>
        <Typography variant="h2" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>Acceder</Typography>
      </Box>

      <Container maxWidth={false} disableGutters sx={{ py: 0 }}>
        <Grid container spacing={0} alignItems="stretch" sx={{ minHeight: '60vh', flexWrap: { xs: 'wrap', md: 'nowrap' } }}>
          <Grid item xs={12} md={6} sx={{ p: 0, m: 0 }}> 
            <Box component="img" src="/img/banner-2.jpg" alt="Banner" sx={{ display: { xs: 'none', md: 'block' }, width: '100%', height: '100%', objectFit: 'cover', m: 0, p: 0, minWidth: { md: '50%' } }} />
          </Grid>
          <Grid item xs={12} md={6} sx={{ display: 'flex', alignItems: 'center', minWidth: { md: '50%' }, p: { xs: 2, md: 6 } }}>
            <Box sx={{ width: '100%' }}>
              <Typography variant="h3" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 900, color: '#99682E', mt: { xs: 0, md: '-1.5rem' }, fontSize: { xs: '1.6rem', md: '2rem' } }}>Bienvenid@</Typography>
              <Box sx={{ mt: 2, width: '100%', maxWidth: 420, mx: { xs: 0, md: 0 } }}>
              <TextField fullWidth label="Email" variant="outlined" sx={{ mb: 2 }} value={email} onChange={(e)=> setEmail(e.target.value)} />
              <TextField fullWidth label="Contraseña" type={showPassword? 'text' : 'password'} variant="outlined" sx={{ mb: 2 }} value={password} onChange={(e)=> setPassword(e.target.value)} InputProps={{ endAdornment: (
                <InputAdornment position="end">
                  <IconButton aria-label="toggle password visibility" onClick={()=> setShowPassword(s => !s)} edge="end">
                    {showPassword ? <VisibilityOff /> : <Visibility />}
                  </IconButton>
                </InputAdornment>
              ) }} />
              {error && <Typography color="error" sx={{ mb: 1 }}>{error}</Typography>}
              <Typography variant="body2" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>No tienes cuenta? <Link component={RouterLink} to="/register" className="tx-nolinea tx-gris">Registrate.</Link></Typography>
              <Box sx={{ mt: 2, display: 'flex', gap: 1 }}>
                <Button variant="contained" sx={{ backgroundColor: '#F75442' }} onClick={handleSubmit} disabled={loading}>{loading? 'Ingresando...' : 'Ingresar'}</Button>
                
              </Box>
            </Box>
          </Box>
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
}
