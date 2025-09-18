// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Lively';

  @override
  String get remaining => 'Restante';

  @override
  String get spent => 'Gasto';

  @override
  String get budget => 'Orçamento';

  @override
  String get noBudget => 'Nenhum orçamento mensal definido';

  @override
  String get setBudget => 'Definir Orçamento';

  @override
  String get history => 'Histórico de Eventos';

  @override
  String get noEvents => 'Nenhum evento ainda';

  @override
  String get addEvent => 'Adicionar Evento';

  @override
  String get editEvent => 'Editar Evento';

  @override
  String get name => 'Nome';

  @override
  String get namePlaceholder => 'Digite o nome do evento';

  @override
  String get value => 'Valor';

  @override
  String get valuePlaceholder => 'Digite o valor';

  @override
  String get deleteConfirm => 'Tem certeza que deseja excluir este evento?';

  @override
  String get delete => 'Excluir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar Alterações';

  @override
  String get add => 'Adicionar Evento';

  @override
  String get nameRequired => 'Digite um nome';

  @override
  String get valueRequired => 'Digite um valor';

  @override
  String get invalidNumber => 'Digite um número válido';

  @override
  String get valuePositive => 'O valor deve ser maior que zero';

  @override
  String get valueTooLarge => 'O valor é muito grande';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get changePhoto => 'Alterar Foto';

  @override
  String get nickname => 'Apelido';

  @override
  String get nicknamePlaceholder => 'Digite seu apelido';

  @override
  String get saveProfile => 'Salvar Perfil';

  @override
  String get profileSaved => 'Perfil salvo';

  @override
  String errorPickingImage(Object error) {
    return 'Erro ao selecionar imagem: $error';
  }

  @override
  String errorSavingProfile(Object error) {
    return 'Erro ao salvar perfil: $error';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get monthlyBudget => 'Orçamento Mensal';

  @override
  String get budgetAmount => 'Valor do Orçamento';

  @override
  String get budgetPlaceholder => 'Digite o orçamento mensal';

  @override
  String get saveBudget => 'Salvar Orçamento';

  @override
  String get budgetSaved => 'Orçamento salvo';

  @override
  String get backup => 'Backup';

  @override
  String get export => 'Exportar para Downloads';

  @override
  String get import => 'Importar dos Downloads';

  @override
  String get importTitle => 'Importar Backup';

  @override
  String get importConfirm => 'Deseja substituir todos os dados existentes pelo backup?';

  @override
  String get merge => 'Mesclar';

  @override
  String get replace => 'Substituir';

  @override
  String backupSaved(Object path) {
    return 'Backup salvo em $path';
  }

  @override
  String get backupImported => 'Backup importado com sucesso';

  @override
  String fileNotFound(Object path) {
    return 'Arquivo de backup não encontrado em $path';
  }

  @override
  String get invalidFormat => 'Formato de backup inválido';

  @override
  String exportError(Object error) {
    return 'Erro ao exportar backup: $error';
  }

  @override
  String importError(Object error) {
    return 'Erro ao importar backup: $error';
  }

  @override
  String error(Object message) {
    return 'Erro: $message';
  }

  @override
  String get ok => 'OK';
}
