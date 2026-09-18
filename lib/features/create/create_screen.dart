import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/app.dart';
import '../../app/app_controller.dart';
import '../../core/design/space_theme.dart';
import '../../data/local_media_service.dart';
import '../projects/projects_screen.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({
    super.key,
    required this.controller,
    required this.onProjectCreated,
  });

  final AppController controller;
  final VoidCallback onProjectCreated;

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _picker = ImagePicker();
  final _media = const LocalMediaService();
  final _description = TextEditingController();
  String? _sourcePath;
  String _roomType = 'Sala';
  String? _message;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1800,
    );
    if (image == null) return;
    final persisted = await _media.persist(image.path);
    if (mounted) setState(() => _sourcePath = persisted);
  }

  Future<void> _create() async {
    final source = _sourcePath;
    if (source == null) {
      setState(() => _message = 'Adicione uma foto do ambiente.');
      return;
    }
    setState(() => _message = null);
    final project = await widget.controller.createProject(
      sourcePath: source,
      roomType: _roomType,
      description: _description.text,
      operationId: 'create-${DateTime.now().microsecondsSinceEpoch}',
    );
    if (!mounted) return;
    widget.onProjectCreated();
    await openProject(context, widget.controller, project.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transformar ambiente')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) => SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 116),
            children: [
              Text(
                'Uma nova visão para o seu espaço',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Envie uma foto frontal e bem iluminada. A proposta seguirá as preferências do seu SpaceDNA.',
                style: TextStyle(color: SpaceColors.muted, height: 1.45),
              ),
              const SizedBox(height: 22),
              _PhotoInput(
                path: _sourcePath,
                onCamera: () => _pick(ImageSource.camera),
                onGallery: () => _pick(ImageSource.gallery),
                onDemo: () =>
                    setState(() => _sourcePath = 'assets/images/room_08.jpg'),
              ),
              const SizedBox(height: 18),
              SpaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhes do projeto',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _roomType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de ambiente',
                      ),
                      items: const ['Sala', 'Quarto', 'Cozinha']
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _roomType = value ?? _roomType),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _description,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'O que você gostaria de mudar?',
                        hintText: 'Ex.: mais aconchego, madeira clara e iluminação indireta',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SpaceCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.insights_outlined,
                      color: SpaceColors.sand,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.controller.dna.isDefined
                            ? 'Seu estilo: ${widget.controller.dna.styles.map((item) => item.label).join(', ')}.'
                            : 'Seu estilo ainda não está definido. A proposta usará a foto, o cômodo e sua descrição.',
                        style: const TextStyle(
                          color: SpaceColors.muted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  style: const TextStyle(color: SpaceColors.error),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: widget.controller.isBusy ? null : _create,
                icon: widget.controller.isBusy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  widget.controller.isBusy
                      ? 'Criando proposta...'
                      : 'Criar proposta',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'MVP demonstrativo: a proposta visual é gerada localmente a partir de modelos incluídos no aplicativo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: SpaceColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoInput extends StatelessWidget {
  const _PhotoInput({
    required this.path,
    required this.onCamera,
    required this.onGallery,
    required this.onDemo,
  });

  final String? path;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 275,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: SpaceColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: path == null ? SpaceColors.outline : SpaceColors.sand,
        ),
      ),
      child: path == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: SpaceColors.sand,
                ),
                const SizedBox(height: 14),
                const Text('Adicione a foto do ambiente'),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: onCamera,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Câmera'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeria'),
                    ),
                    TextButton(
                      onPressed: onDemo,
                      child: const Text('Usar exemplo'),
                    ),
                  ],
                ),
              ],
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                _SelectedImage(path: path!),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xB8181715)],
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: IconButton.filledTonal(
                    tooltip: 'Trocar foto',
                    onPressed: onGallery,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
                const Positioned(
                  left: 18,
                  bottom: 16,
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: SpaceColors.sand),
                      SizedBox(width: 8),
                      Text('Foto pronta'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SelectedImage extends StatelessWidget {
  const _SelectedImage({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return path.startsWith('assets/')
        ? Image.asset(path, fit: BoxFit.cover)
        : Image.file(File(path), fit: BoxFit.cover);
  }
}
