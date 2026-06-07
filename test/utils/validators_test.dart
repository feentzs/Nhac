import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/utils/validators.dart';

void main() {
  group('Validators Tests (Segurança de Input)', () {
    test('Deve validar emails corretamente', () {
      expect(Validators.validarEmail(''), 'E-mail obrigatório');
      expect(Validators.validarEmail(' '), 'E-mail obrigatório');
      expect(Validators.validarEmail('joao@.com'), 'E-mail inválido');
      expect(Validators.validarEmail('joao.com'), 'E-mail inválido');
      expect(Validators.validarEmail('joao!@gmail.com'), 'Caracteres inválidos (use apenas letras, números, @ e ponto)');
      expect(Validators.validarEmail('joao@gmail.com'), null);
    });

    test('Deve exigir senhas fortes (8+ chars, 1 uppercase)', () {
      expect(Validators.validarSenha(''), 'Senha obrigatória');
      expect(Validators.validarSenha('123'), 'Mínimo de 8 caracteres');
      expect(Validators.validarSenha('senhaforte123'), 'Precisa de pelo menos uma letra maiúscula');
      expect(Validators.validarSenha('SenhaForte123'), null);
    });
    
    test('Deve validar telefones corretamente', () {
      expect(Validators.validarTelefone(''), 'Telefone obrigatório');
      expect(Validators.validarTelefone('abc'), 'O telefone não pode conter letras ou caracteres especiais');
      expect(Validators.validarTelefone('119999'), 'Tamanho inválido (deve ter 10 ou 11 números)');
      expect(Validators.validarTelefone('11999999999'), null);
      expect(Validators.validarTelefone('(11) 99999-9999'), null);
    });

    test('Deve validar CPF corretamente', () {
      expect(Validators.validarCPF(''), 'CPF obrigatório');
      expect(Validators.validarCPF('123'), 'O CPF deve ter 11 dígitos');
      expect(Validators.validarCPF('11111111111'), 'CPF inválido');
      // CPF válido gerado para teste: 52998224725
      expect(Validators.validarCPF('52998224725'), null);
      expect(Validators.validarCPF('529.982.247-25'), null);
    });

    test('Deve validar nome corretamente', () {
      expect(Validators.validarNome(''), 'Campo obrigatório');
      expect(Validators.validarNome('A'), 'O nome deve ter pelo menos 2 letras');
      expect(Validators.validarNome('Joã0'), 'O nome não pode conter números ou caracteres especiais');
      expect(Validators.validarNome('João Silva'), null);
    });
  });
}