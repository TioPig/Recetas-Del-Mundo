document.addEventListener("DOMContentLoaded", function () {
  const annoDiv = document.getElementById("anno");
  const añoActual = new Date().getFullYear(); // Obtener el año actual
  annoDiv.innerHTML =
    añoActual +
    ", Recetas del mundo - un sitio donde podrás encontrar la receta perfecta para esa ocasión.";
});

/*-- Cargar Paises en NavDropdown --*/
document.addEventListener("DOMContentLoaded", function () {
  const paisesUrl = "https://apirecetas.iacst.space/pais/";
  const dropdownMenuId = "navbarDropdownPaisesMenu";
  const dropdownToggleId = "navbarDropdownPaises";

  function cargarPaisesDropdown(paisesUrl, dropdownMenuId, dropdownToggleId) {
    const dropdownMenu = document.getElementById(dropdownMenuId);
    const dropdownToggle = document.getElementById(dropdownToggleId);

    fetch(paisesUrl)
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        if (data.ok && Array.isArray(data.data)) {
          data.data.forEach((pais) => {
            const li = document.createElement("li");
            const a = document.createElement("a");
            a.classList.add("dropdown-item");
            a.href = `comidas-por-pais.html?pais=${encodeURIComponent(
              pais.nombre
            )}`;
            a.textContent = pais.nombre;
            li.appendChild(a);
            dropdownMenu.appendChild(li);
          });
        } else {
          dropdownMenu.innerHTML = `<li><a class="dropdown-item">Formato de datos inesperado</a></li>`;
        }
      })
      .catch((error) => {
        dropdownMenu.innerHTML = `<li><a class="dropdown-item">Error al cargar los países: ${error.message}</a></li>`;
      });
  }

  cargarPaisesDropdown(paisesUrl, dropdownMenuId, dropdownToggleId);
});

/*-- Cargar Categorias en NavDropdown --*/
document.addEventListener("DOMContentLoaded", function () {
  const categoriasUrl = "https://apirecetas.iacst.space/categoria/";
  const dropdownMenuId = "navbarDropdownCategoriasMenu";
  const dropdownToggleId = "navbarDropdownCategorias";

  function cargarCategoriasDropdown(
    categoriasUrl,
    dropdownMenuId,
    dropdownToggleId
  ) {
    const dropdownMenu = document.getElementById(dropdownMenuId);
    const dropdownToggle = document.getElementById(dropdownToggleId);

    fetch(categoriasUrl)
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        if (data.ok && Array.isArray(data.data)) {
          data.data.forEach((categoria) => {
            const li = document.createElement("li");
            const a = document.createElement("a");
            a.classList.add("dropdown-item");
            a.href = `comidas-por-categoria.html?categoria=${encodeURIComponent(
              categoria.nombre
            )}`;
            a.textContent = categoria.nombre;
            li.appendChild(a);
            dropdownMenu.appendChild(li);
          });
        } else {
          dropdownMenu.innerHTML = `<li><a class="dropdown-item">Formato de datos inesperado</a></li>`;
        }
      })
      .catch((error) => {
        dropdownMenu.innerHTML = `<li><a class="dropdown-item">Error al cargar las categorías: ${error.message}</a></li>`;
      });
  }

  cargarCategoriasDropdown(categoriasUrl, dropdownMenuId, dropdownToggleId);
});

/* Cargar Paises en el Index */
document.addEventListener("DOMContentLoaded", function () {
  if (window.location.pathname === "/index.html") { 
    const paisesUrl = "https://apirecetas.iacst.space/pais/";
    const paisesDiv = document.getElementById("pais");
    function cargarPaises() {
      fetch(paisesUrl)
        .then((response) => {
          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
          }
          return response.json();
        })
        .then((data) => {
          if (data.ok && Array.isArray(data.data)) {
            data.data.forEach((pais, index) => {
              const paisDiv = document.createElement("div");
              paisDiv.classList.add("col-md-3", "mb-4");

              const paisImg = document.createElement("img");
              paisImg.classList.add(
                "img-fluid",
                "img-thumbnail",
                "pais-img",
                "categoria-img"
              );
              paisImg.src = pais.url_imagen;
              paisImg.alt = pais.nombre;
              paisDiv.appendChild(paisImg);

              const paisBtn = document.createElement("button");
              paisBtn.classList.add(
                "btn",
                "w-100",
                "mt-2",
                "bg-naranjo",
                "tx-blanco"
              );
              paisBtn.textContent = `${pais.nombre}`;
              paisBtn.addEventListener("click", function () {
                // Redirigir a la página específica del país
                window.location.href = `comidas-por-pais.html?pais=${encodeURIComponent(
                  pais.nombre
                )}`;
              });
              paisDiv.appendChild(paisBtn);

              paisesDiv.appendChild(paisDiv);
            });
          } else {
            paisesDiv.innerHTML = `<p>Formato de datos inesperado</p>`;
          }
        })
        .catch((error) => {
          paisesDiv.innerHTML = `<p>Error al cargar los países: ${error.message}</p>`;
        });
    }

    cargarPaises();
  }
});

document.addEventListener("DOMContentLoaded", function () {
  const recetasUrl = "https://apirecetas.iacst.space/recetas"; // Endpoint para obtener todas las recetas
  const recetaRandomLink = document.getElementById("recetaRandomLink");
  const recetaAleatoriaModal = new bootstrap.Modal(
    document.getElementById("recetaAleatoriaModal")
  );
  const recetaAleatoriaModalBody = document.getElementById(
    "recetaAleatoriaModalBody"
  );
  const recetaAleatoriaModalLabel = document.getElementById(
    "recetaAleatoriaModalLabel"
  );

  // Función para cargar todas las recetas y seleccionar una aleatoria
  function cargarRecetaAleatoria() {
    fetch(recetasUrl)
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        if (data.ok && Array.isArray(data.data)) {
          const recetas = data.data;
          const receta = recetas[Math.floor(Math.random() * recetas.length)];
          const modalId = `modalAleatoria`;

          recetaAleatoriaModalLabel.textContent = receta.nombre;
          recetaAleatoriaModalBody.innerHTML = `
                          <img class="w-100 mb-3" src="${
                            receta.url_imagen
                          }" alt="${receta.nombre}">
                          <p style="text-align: justify !important;"><strong>Ingredientes:</strong> ${receta.ingrediente.replace(
                            /\\n/g,
                            ", "
                          )}</p>
                          <p style="text-align: justify !important;"><strong>Preparación:</strong> ${
                            receta.preparacion
                          }</p>
                      `;

          // Mostrar el modal
          recetaAleatoriaModal.show();
        } else {
          recetaAleatoriaModalBody.innerHTML = `<p>No se pudo cargar una receta aleatoria.</p>`;
        }
      })
      .catch((error) => {
        recetaAleatoriaModalBody.innerHTML = `<p>Error al cargar la receta aleatoria: ${error.message}</p>`;
      });
  }

  // Asignar el evento click al enlace de receta aleatoria
  recetaRandomLink.addEventListener("click", function (event) {
    event.preventDefault();
    cargarRecetaAleatoria();
  });
});


document.addEventListener("DOMContentLoaded", function () {
    const paths = ["/index.html", "/login.html", "/register.html"];
    // El siguiente if no funciona en local, tendrian que poenr el directorio en su totalidad
    // Ej: /C:/Users/*USUARIO*/Documents/GitHub/RDM/login.html
    if (paths.includes(window.location.pathname)) {
      const recetasUrl = "https://apirecetas.iacst.space/recetas"; // Endpoint para obtener todas las recetas
      const recetaRandomLink = document.getElementById("recetaRandomLink");
      const recetaDelDiaNombre = document.getElementById("recetaDelDiaNombre");
      const recetaDelDiaDescripcion = document.getElementById("recetaDelDiaDescripcion");
      const recetaDelDiaImg = document.getElementById("recetaDelDiaImg");
  
      function esMismaFecha(fecha1, fecha2) {
        return (
          fecha1.getFullYear() === fecha2.getFullYear() &&
          fecha1.getMonth() === fecha2.getMonth() &&
          fecha1.getDate() === fecha2.getDate()
        );
      }
  
      function cargarRecetaAleatoria() {
        fetch(recetasUrl)
          .then((response) => {
            if (!response.ok) {
              throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
          })
          .then((data) => {
            if (data.ok && Array.isArray(data.data)) {
              const recetaAleatoria = data.data[Math.floor(Math.random() * data.data.length)];
  
              const recetaDelDia = {
                nombre: recetaAleatoria.nombre,
                ingrediente: recetaAleatoria.ingrediente,
                preparacion: recetaAleatoria.preparacion,
                url_imagen: recetaAleatoria.url_imagen,
                fecha: new Date().toISOString()
              };
  
              localStorage.setItem("recetaDelDia", JSON.stringify(recetaDelDia));
  
              mostrarRecetaDelDia(recetaDelDia);
            } else {
              recetaDelDiaDescripcion.textContent = "No hay recetas disponibles.";
            }
          })
          .catch((error) => {
            recetaDelDiaDescripcion.innerHTML = `<p>Error al cargar la receta aleatoria: ${error.message}</p>`;
          });
      }
  
      function mostrarRecetaDelDia(receta) {
        recetaDelDiaNombre.textContent = receta.nombre;
        recetaDelDiaDescripcion.innerHTML = `
          <p style="text-align: justify !important;"><strong>Ingredientes:</strong> ${receta.ingrediente.replace(
            /\\n/g,
            ", "
          )}</p>
          <p style="text-align: justify !important;"><strong>Preparación:</strong> ${receta.preparacion}</p>
        `;
        recetaDelDiaImg.src = receta.url_imagen;
        recetaDelDiaImg.classList.add("random-img");
        recetaDelDiaImg.alt = receta.nombre;
      }
  
      function inicializarRecetaDelDia() {
        const recetaGuardada = JSON.parse(localStorage.getItem("recetaDelDia"));
  
        if (recetaGuardada && esMismaFecha(new Date(recetaGuardada.fecha), new Date())) {
          mostrarRecetaDelDia(recetaGuardada);
        } else {
          cargarRecetaAleatoria();
        }
      }
  
      // Inicializar la receta del día al acceder a la página
      inicializarRecetaDelDia();
    }
  });
  