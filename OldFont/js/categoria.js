document.addEventListener("DOMContentLoaded", function() {
    const categoriasUrl = "https://apirecetas.iacst.space/categoria/";
    const recetasUrlBase = "https://apirecetas.iacst.space/recetas/";
    const categoriasDiv = document.getElementById("categorias");
    const recetasDiv = document.getElementById("recetas");
    const nombreCategoria = document.getElementById("nombreCategoria"); // Seleccionar el elemento del título
    let categoriaPredeterminada = "Desayuno"; // Valor predeterminado inicial

    // Función para cargar categorías
    function cargarCategorias() {
        fetch(categoriasUrl)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                if (Array.isArray(data.data)) {
                    data.data.forEach((categoria, index) => {
                        const categoriaDiv = document.createElement("div");
                        categoriaDiv.classList.add("col-md-3", "mb-4");
                        
                        const categoriaImg = document.createElement("img");
                        categoriaImg.classList.add("img-fluid", "img-thumbnail", "categoria-img");
                        categoriaImg.src = categoria.url_imagen;
                        categoriaImg.alt = categoria.nombre;
                        categoriaDiv.appendChild(categoriaImg);

                        const categoriaBtn = document.createElement("button");
                        categoriaBtn.classList.add("btn", "w-100", "mt-2", "bg-naranjo", "tx-blanco");
                        categoriaBtn.textContent = `${categoria.nombre}`;
                        categoriaBtn.addEventListener("click", function() {
                            cargarRecetas(categoria.nombre);
                            window.scrollTo({ top: 0, behavior: 'smooth' }); // Desplazar hacia arriba
                        });
                        categoriaDiv.appendChild(categoriaBtn);

                        categoriasDiv.appendChild(categoriaDiv);
                    });
                } else {
                    categoriasDiv.innerHTML = `<p>Formato de datos inesperado</p>`;
                }
            })
            .catch(error => {
                categoriasDiv.innerHTML = `<p>Error al cargar las categorías: ${error.message}</p>`;
            });
    }

    // Función para cargar recetas
    function cargarRecetas(categoria) {
        const recetasUrl = recetasUrlBase + (categoria ? "categoria/" + categoria : ""); // Si no se proporciona categoría, se cargan todas las recetas
        if (categoria != "") {
            nombreCategoria.textContent = categoria; // Actualizar el título con el nombre de la categoría
        }
        // Limpiar recetas anteriores
        recetasDiv.innerHTML = '';
        
        fetch(recetasUrl)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            if (data.ok) {
                if (Array.isArray(data.data) && data.data.length > 0) {
                    data.data.forEach((receta, index) => {
                        const modalId = `modal${index}`;
                        const recetaElement = document.createElement("div");
                        recetaElement.classList.add("col-md-3");
                        recetaElement.innerHTML = `
                            <div class="card mb-4">
                                <img src="${receta.url_imagen}" class="card-img-top img-thumbnail receta-img" alt="${receta.nombre}">
                                <div class="card-body">
                                    <h5 class="card-title titulo-card">${receta.nombre}</h5>
                                    <p class="card-text">Categoria: ${receta.nombre_cat}
                                    <br> País: ${receta.nombre_pais}
                                    </p>
                                    <button class="btn bg-naranjo tx-blanco" style="width: 100%;" type="button" data-bs-toggle="modal" data-bs-target="#${modalId}">Ver receta</button>
                                </div>
                            </div>

                            <!-- Modal -->
                            <div class="modal fade modal-lg" style="text-align: justify !important;" id="${modalId}" tabindex="-1" aria-labelledby="${modalId}Label" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="${modalId}Label">${receta.nombre}</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <img class="w-100 mb-3" src="${receta.url_imagen}" alt="${receta.nombre}">
                                            <p><strong>Ingredientes:</strong> ${receta.ingrediente.replace(/\\n/g, ', ')}</p>
                                            <p><strong>Preparación:</strong> ${receta.preparacion}</p>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-warning" data-bs-dismiss="modal">Cerrar</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        `;
                        recetasDiv.appendChild(recetaElement);
                    });
                    nombreCategoria.textContent = categoria ? categoria : "Todas las Recetas"; // Actualizar el título con el nombre de la categoría o "Todas las Recetas" si no se proporciona categoría
                } else {
                    recetasDiv.innerHTML = `<p class="texto-mediano tx-cafe">No hay recetas disponibles para esta categoría.</p>`;
                }
            } else {
                recetasDiv.innerHTML = `<p>Error en la respuesta de la API.</p>`;
            }
        })
        .catch(error => {
            recetasDiv.innerHTML = `<p>Error al cargar las recetas: ${error.message}</p>`;
        });
    }

    // Función para obtener la categoría predeterminada desde la API
    function obtenerCategoriaPredeterminada() {
        return fetch(categoriasUrl)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                if (Array.isArray(data.data) && data.data.length > 0) {
                    return data.data[0].nombre; // Devuelve el nombre de la primera categoría
                } else {
                    throw new Error("No se encontraron categorías en la API");
                }
            })
            .catch(error => {
                console.error(`Error al obtener la categoría predeterminada: ${error.message}`);
                return categoriaPredeterminada; // Si hay un error, usar el valor inicial predeterminado
            });
    }

    // Leer el parámetro de la consulta "categoria" de la URL
    const params = new URLSearchParams(window.location.search);
    const categoria = params.get('categoria');

    // Obtener la categoría predeterminada desde la API y luego cargar las recetas
    obtenerCategoriaPredeterminada().then(predeterminada => {
        cargarRecetas(categoria ? categoria : predeterminada);
    });

    cargarCategorias();

});
