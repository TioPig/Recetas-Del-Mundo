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

const RatingDialog = ({ open, onClose, onRate, recetaNombre }) => {
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

  const handleCancel = () => {
    setValue(5);
    onClose();
  };

  return (
    <Dialog open={open} onClose={handleCancel} maxWidth="sm" fullWidth>
      <DialogTitle>Califica la receta</DialogTitle>
      <DialogContent>
        <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2, py: 2 }}>
          <Typography variant="body1" sx={{ fontWeight: 500 }}>
            {recetaNombre}
          </Typography>
          <Rating
            name="star-rating"
            value={value}
            onChange={(event, newValue) => {
              setValue(newValue);
            }}
            precision={1}
            size="large"
            emptyIcon={<StarIcon style={{ opacity: 0.55 }} fontSize="inherit" />}
          />
          <Typography variant="body2" color="text.secondary">
            {value} {value === 1 ? 'estrella' : 'estrellas'}
          </Typography>
        </Box>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleCancel} color="inherit">
          Cancelar
        </Button>
        <Button onClick={handleSubmit} variant="contained" color="primary">
          Calificar
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default RatingDialog;
