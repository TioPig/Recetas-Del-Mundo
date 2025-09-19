import React from 'react';
import Dialog from '@mui/material/Dialog';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import Button from '@mui/material/Button';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import { useNavigate } from 'react-router-dom';

export default function AuthPromptDialog({ open, onClose }){
  const navigate = useNavigate();
  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogContent sx={{ p: 2, minHeight: 260 }}>
        <Box sx={{ display: 'flex', flexDirection: 'row', alignItems: 'stretch', gap: 0, flexWrap: 'nowrap', height: '100%' }}>
          {/* Left column: content and buttons at bottom */}
          <Box sx={{ flex: 1, p: 2, display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
            <Box>
              <Typography sx={{ color: '#99682E', fontFamily: 'Lato, sans-serif', fontWeight: 800, mb: 1, fontSize: '1.25rem' }}>Únete al Mundo Culinario</Typography>
              <Typography sx={{ color: '#969696' }}>Para usar favoritos, me gusta, estrellas y comentar debes iniciar sesión o crear una cuenta.</Typography>
            </Box>
            <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
              <Button onClick={()=>{ onClose(); navigate('/login'); }} variant="outlined" sx={{ color: '#F75442', borderColor: '#F75442' }}>Iniciar sesión</Button>
              <Button onClick={()=>{ onClose(); navigate('/register'); }} variant="contained" sx={{ backgroundColor: '#F75442', '&:hover': { backgroundColor: '#d64a3d' } }}>Crear cuenta</Button>
            </Box>
          </Box>

          {/* Right column: image fills column with no margins (neutralize DialogContent padding) */}
          <Box sx={{ flex: 1, display: 'flex', alignItems: 'stretch', justifyContent: 'center', mt: -2, mb: -2, mr: -2 }}>
            <Box component="img" src="/img/chef.jpg" alt="Chef" sx={{ width: 'calc(100% + 16px)', height: '100%', objectFit: 'cover', borderRadius: 0, m: 0, p: 0, display: 'block' }} />
          </Box>
        </Box>
      </DialogContent>
    </Dialog>
  );
}
