import React from 'react';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import Grid from '@mui/material/Grid';
import { register } from '../api';

export default function Register(){
  const [nombre, setNombre] = useState('');
  const [apellido, setApellido] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [password2, setPassword2] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleRegister = async () => {
    setError(null);
    if(!nombre || !apellido || !email || !password){ 
      setError('Completa todos los campos requeridos'); 
      return; 
    }
    if(password !== password2){ 
      setError('Las contraseñas no coinciden'); 
      return; 
    }
    setLoading(true);
    try{
      // Enviar en el formato que espera el backend
      const payload = { 
        nombre, 
        apellido, 
        email, 
        password 
      };
      const response = await register(payload);
      setLoading(false);
      
      // Verificar si el registro fue exitoso
      if (response.data && response.data.exito) {
        navigate('/login');
      } else {
        setError(response.data?.mensaje || 'Error al crear la cuenta');
      }
    }catch(e){
      setLoading(false);
      const errorMsg = e.response?.data?.mensaje || 'Error al crear la cuenta. Intenta de nuevo.';
      setError(errorMsg);
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
              <TextField 
                label="Nombre" 
                value={nombre} 
                onChange={(e)=> setNombre(e.target.value)} 
                fullWidth 
                required
              />
              <TextField 
                label="Apellido" 
                value={apellido} 
                onChange={(e)=> setApellido(e.target.value)} 
                fullWidth 
                required
              />
              <TextField 
                label="Email" 
                value={email} 
                onChange={(e)=> setEmail(e.target.value)} 
                type="email" 
                fullWidth 
                required
              />
              <TextField 
                label="Contraseña" 
                value={password} 
                onChange={(e)=> setPassword(e.target.value)} 
                type="password" 
                fullWidth 
                required
              />
              <TextField 
                label="Confirmar Contraseña" 
                value={password2} 
                onChange={(e)=> setPassword2(e.target.value)} 
                type="password" 
                fullWidth 
                required
              />
              {error && <Typography color="error">{error}</Typography>}
              <Box sx={{ display: 'flex', gap: 1 }}>
                <Button 
                  variant="contained" 
                  sx={{ backgroundColor: '#F75442', '&:hover': { backgroundColor: '#d64032' } }} 
                  onClick={handleRegister} 
                  disabled={loading}
                >
                  {loading? 'Creando...' : 'Crear cuenta'}
                </Button>
                <Button variant="outlined" onClick={()=> navigate('/login')}>Volver</Button>
              </Box>
            </Box>
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
}
