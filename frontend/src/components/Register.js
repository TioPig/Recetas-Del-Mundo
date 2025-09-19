import React from 'react';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import Grid from '@mui/material/Grid';
import { postUsuario } from '../api';

export default function Register(){
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [password2, setPassword2] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleRegister = async () => {
    setError(null);
    if(!username || !email || !password){ setError('Completa los campos requeridos'); return; }
    if(password !== password2){ setError('Las contraseñas no coinciden'); return; }
    setLoading(true);
    try{
      const payload = { username, email, password };
      await postUsuario(payload);
      setLoading(false);
      navigate('/login');
    }catch(e){
      setLoading(false);
      setError('Error al crear la cuenta. Intenta de nuevo.');
    }
  };

  return (
    <Box>
      <Box sx={{ textAlign: 'center', backgroundColor: '#F9E9AE', py: 4 }}>
        <Typography variant="h2" sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>Crear cuenta</Typography>
      </Box>

      <Container sx={{ py: 4 }}>
        <Grid container justifyContent="center">
          <Grid item xs={12} md={6}>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              <TextField label="Usuario" value={username} onChange={(e)=> setUsername(e.target.value)} fullWidth />
              <TextField label="Email" value={email} onChange={(e)=> setEmail(e.target.value)} type="email" fullWidth />
              <TextField label="Contraseña" value={password} onChange={(e)=> setPassword(e.target.value)} type="password" fullWidth />
              <TextField label="Confirmar Contraseña" value={password2} onChange={(e)=> setPassword2(e.target.value)} type="password" fullWidth />
              {error && <Typography color="error">{error}</Typography>}
              <Box sx={{ display: 'flex', gap: 1 }}>
                <Button variant="contained" sx={{ backgroundColor: '#F75442' }} onClick={handleRegister} disabled={loading}>{loading? 'Creando...' : 'Crear cuenta'}</Button>
                <Button variant="outlined" onClick={()=> navigate('/login')}>Volver</Button>
              </Box>
            </Box>
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
}
