import React from 'react';
import {
  Box,
  TextField,
  InputAdornment,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  IconButton,
  Tooltip
} from '@mui/material';
import {
  Search as SearchIcon,
  Clear as ClearIcon
} from '@mui/icons-material';

function SearchFilter({ 
  searchValue, 
  onSearchChange, 
  searchPlaceholder = "Buscar...",
  filterValue,
  onFilterChange,
  filterLabel,
  filterOptions = [],
  showFilter = false
}) {
  const handleClearSearch = () => {
    onSearchChange({ target: { value: '' } });
  };

  const handleClearFilter = () => {
    if (onFilterChange) {
      onFilterChange({ target: { value: '' } });
    }
  };

  return (
    <Box sx={{ 
      display: 'flex', 
      gap: 2, 
      mb: 3, 
      flexWrap: 'wrap',
      alignItems: 'center'
    }}>
      <TextField
        placeholder={searchPlaceholder}
        value={searchValue}
        onChange={onSearchChange}
        variant="outlined"
        size="small"
        sx={{ 
          flexGrow: 1, 
          minWidth: { xs: '100%', sm: '250px' },
          maxWidth: { xs: '100%', sm: '400px' }
        }}
        InputProps={{
          startAdornment: (
            <InputAdornment position="start">
              <SearchIcon color="action" />
            </InputAdornment>
          ),
          endAdornment: searchValue && (
            <InputAdornment position="end">
              <Tooltip title="Limpiar búsqueda">
                <IconButton
                  size="small"
                  onClick={handleClearSearch}
                  edge="end"
                >
                  <ClearIcon fontSize="small" />
                </IconButton>
              </Tooltip>
            </InputAdornment>
          )
        }}
      />
      
      {showFilter && filterOptions.length > 0 && (
        <FormControl 
          size="small" 
          sx={{ 
            minWidth: { xs: '100%', sm: 200 },
            maxWidth: { xs: '100%', sm: 250 }
          }}
        >
          <InputLabel>{filterLabel}</InputLabel>
          <Select
            value={filterValue}
            onChange={onFilterChange}
            label={filterLabel}
            endAdornment={
              filterValue && (
                <InputAdornment position="end" sx={{ mr: 3 }}>
                  <Tooltip title="Limpiar filtro">
                    <IconButton
                      size="small"
                      onClick={handleClearFilter}
                      edge="end"
                    >
                      <ClearIcon fontSize="small" />
                    </IconButton>
                  </Tooltip>
                </InputAdornment>
              )
            }
          >
            <MenuItem value="">
              <em>Todos</em>
            </MenuItem>
            {filterOptions.map((option) => (
              <MenuItem key={option.value} value={option.value}>
                {option.label}
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      )}
    </Box>
  );
}

export default SearchFilter;
