import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Rating,
  Typography,
  Box
} from '@mui/material';
import StarIcon from '@mui/icons-material/Star';
import DeleteIcon from '@mui/icons-material/Delete';

const RatingDialog = ({ open, onClose, onRate, onDelete, recetaNombre, hasRating }) => {
  const [value, setValue] = useState(5);

  // Reset value to 5 when dialog closes or opens
  useEffect(() => {
    if (open) {
      setValue(5);
    }
  }, [open]);

  const handleSubmit = () => {
    onRate(value);
    setValue(5);
    onClose();
  };

  const handleDelete = () => {
    if (onDelete) {
      onDelete();
    }
    setValue(5);
    onClose();
  };

  const handleCancel = () => {
    setValue(5);
    onClose();
  };

  return (
    <Dialog 
      open={open} 
      onClose={handleCancel} 
      maxWidth="sm" 
      fullWidth
      PaperProps={{
        sx: {
          borderRadius: 3,
          boxShadow: '0 8px 32px rgba(102, 126, 234, 0.15)'
        }
      }}
    >
      <DialogTitle sx={{
        fontFamily: 'Roboto, sans-serif',
        fontWeight: 900,
        color: '#1A202C',
        fontSize: '1.5rem',
        pb: 1,
        borderBottom: '2px solid #E2E8F0'
      }}>
        Califica la receta
      </DialogTitle>
      <DialogContent sx={{ pt: 3 }}>
        <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2, py: 2 }}>
          <Typography sx={{ 
            fontFamily: 'Lato, sans-serif',
            fontWeight: 700,
            color: '#2D3748',
            fontSize: '1.1rem',
            textAlign: 'center'
          }}>
            {recetaNombre}
          </Typography>
          <Rating
            name="star-rating"
            value={value}
            onChange={(event, newValue) => {
              if (newValue === null || newValue === 0) {
                setValue(1);
              } else {
                setValue(newValue);
              }
            }}
            precision={1}
            size="large"
            emptyIcon={<StarIcon style={{ opacity: 0.55 }} fontSize="inherit" />}
            sx={{
              '& .MuiRating-iconFilled': {
                color: '#ED8936'
              },
              '& .MuiRating-iconHover': {
                color: '#DD6B20'
              }
            }}
          />
          <Typography sx={{
            fontFamily: 'Open Sans, sans-serif',
            color: '#718096',
            fontSize: '0.95rem'
          }}>
            {value} {value === 1 ? 'estrella' : 'estrellas'}
          </Typography>
        </Box>
      </DialogContent>
      <DialogActions sx={{ justifyContent: hasRating ? 'space-between' : 'flex-end', px: 3, pb: 2.5 }}>
        {hasRating && (
          <Button 
            onClick={handleDelete} 
            startIcon={<DeleteIcon />}
            sx={{
              color: '#F56565',
              borderColor: '#F56565',
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 600,
              borderRadius: 50,
              px: 2.5,
              '&:hover': {
                borderColor: '#E53E3E',
                backgroundColor: 'rgba(245, 101, 101, 0.04)'
              }
            }}
            variant="outlined"
          >
            Eliminar valoración
          </Button>
        )}
        <Box>
          <Button 
            onClick={handleCancel}
            sx={{
              color: '#718096',
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 600,
              mr: 1,
              '&:hover': {
                backgroundColor: 'rgba(113, 128, 150, 0.08)'
              }
            }}
          >
            Cancelar
          </Button>
          <Button 
            onClick={handleSubmit}
            variant="contained"
            sx={{
              background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
              color: 'white',
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 700,
              borderRadius: 50,
              px: 3,
              '&:hover': {
                background: 'linear-gradient(135deg, #F5576C 0%, #F093FB 100%)',
                transform: 'translateY(-2px)',
                boxShadow: '0 4px 12px rgba(240, 147, 251, 0.4)'
              },
              transition: 'all 0.3s ease'
            }}
          >
            Calificar
          </Button>
        </Box>
      </DialogActions>
    </Dialog>
  );
};

export default RatingDialog;
