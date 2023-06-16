import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {


/// Cette fonction permet de sélectionner une image depuis la galerie du périphérique.
/// Elle renvoie un objet [File] représentant le fichier de l'image sélectionnée, ou [null] si aucune image n'a été sélectionnée ou s'il y a eu une erreur.
static Future<File?> pickImageFromGallery() async {
  try {
    // Utilise l'objet [ImagePicker] pour sélectionner une image depuis la galerie.
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    
    // Vérifie si aucune image n'a été sélectionnée.
    if (image == null) return null;
    
    // Convertit le chemin de l'image en un objet [File].
    final imageFile = File(image.path);
    
    // Renvoie le fichier de l'image sélectionnée.
    return imageFile;
  } catch (e) {
    // Affiche un message d'erreur en cas d'échec de la sélection de l'image.
    print("Échec de la sélection de l'image depuis la galerie : $e");
    
    // Renvoie [null] en cas d'erreur.
    return null;
  }
}


/// Sélectionne une image à partir de l'appareil photo.
///
/// Cette fonction permet à l'utilisateur de prendre une photo à l'aide de l'appareil photo
/// de l'appareil. Elle utilise la classe ImagePicker pour afficher l'interface de l'appareil
/// photo et permettre à l'utilisateur de capturer une image.
///
/// Returns:
///   - Un objet File contenant l'image capturée si l'utilisateur a sélectionné une image.
///   - Null si l'utilisateur a annulé la capture de l'image ou s'il y a eu une erreur lors de la sélection.
static Future<File?> pickImageFromCamera() async {
  try {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return null;
    final imageFile = File(image.path);
    return imageFile;
  } catch (e) {
    print("Échec de la sélection de l'image à partir de l'appareil photo : $e");
    return null;
  }
}

}
