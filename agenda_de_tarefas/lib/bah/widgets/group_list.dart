import 'package:flutter/material.dart';

class group_list extends StatelessWidget {
  final int id;
  final String donoDogrupo;
  final String nome;
  final String descricao;

  const group_list({
    Key? key,
    required this.id,
    required this.donoDogrupo,
    required this.nome,
    required this.descricao,
  }) : super(key: key);

  void goToPageGroup() {
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8DDCE),
        borderRadius: BorderRadius.circular(8),  // Aumentando o arredondamento
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),  // Cor da sombra
            blurRadius: 8,  // Definindo o desfoque da sombra
            spreadRadius: 2,  // Controle do quanto a sombra se espalha
            offset: const Offset(0, 4),  // Posição da sombra (offset no eixo X e Y)
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF8DDCE),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,  // Remove a sombra padrão do ElevatedButton
        ),
        onPressed: goToPageGroup,
        child: Row(
          children: [
            const Icon(
              Icons.group,
              color: Colors.black,
            ),
            Text(
              nome,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
