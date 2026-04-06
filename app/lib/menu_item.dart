import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String title; // Texto que se muestra en el botón.
  final String imagePath; // Ruta de la imagen de fondo.
  final Widget targetScreen; // Pantalla a la que se navega al hacer clic.

  const MenuItem({
    required this.title,
    required this.imagePath,
    required this.targetScreen,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0), // Espaciado entre botones.
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath), // Configura la imagen de fondo.
            fit: BoxFit.cover, // Ajusta la imagen al tamaño del contenedor.
          ),
          borderRadius: BorderRadius.circular(12.0), // Esquinas redondeadas.
        ),
        height: 150, // Altura del botón.
        child: Center(
          child: Text(
            title, // Muestra el texto del botón.
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 3,
                  color: Colors.black26, // Sombra para mejorar visibilidad.
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
