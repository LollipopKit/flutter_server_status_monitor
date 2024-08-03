import 'dart:convert';

import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:server_box/core/extension/context/locale.dart';
import 'package:server_box/data/model/server/snippet.dart';
import 'package:server_box/data/res/provider.dart';
import 'package:icons_plus/icons_plus.dart';

class SnippetEditPage extends StatefulWidget {
  const SnippetEditPage({super.key, this.snippet});

  final Snippet? snippet;

  @override
  State<SnippetEditPage> createState() => _SnippetEditPageState();
}

class _SnippetEditPageState extends State<SnippetEditPage>
    with AfterLayoutMixin {
  final _nameController = TextEditingController();
  final _scriptController = TextEditingController();
  final _noteController = TextEditingController();
  final _scriptNode = FocusNode();
  final _autoRunOn = ValueNotifier(<String>[]);
  final _tags = <String>{}.vn;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _scriptController.dispose();
    _scriptNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(l10n.edit),
        actions: _buildAppBarActions(),
      ),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  List<Widget>? _buildAppBarActions() {
    if (widget.snippet == null) return null;
    return [
      IconButton(
        onPressed: () {
          context.showRoundDialog(
            title: l10n.attention,
            child: Text(l10n.askContinue(
              '${l10n.delete} ${l10n.snippet}(${widget.snippet!.name})',
            )),
            actions: [
              TextButton(
                onPressed: () {
                  Pros.snippet.del(widget.snippet!);
                  context.pop();
                  context.pop();
                },
                child: Text(l10n.ok, style: UIs.textRed),
              ),
            ],
          );
        },
        tooltip: l10n.delete,
        icon: const Icon(Icons.delete),
      )
    ];
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      heroTag: 'snippet',
      child: const Icon(Icons.save),
      onPressed: () {
        final name = _nameController.text;
        final script = _scriptController.text;
        if (name.isEmpty || script.isEmpty) {
          context.showSnackBar(l10n.fieldMustNotEmpty);
          return;
        }
        final note = _noteController.text;
        final snippet = Snippet(
          name: name,
          script: script,
          tags: _tags.value.isEmpty ? null : _tags.value.toList(),
          note: note.isEmpty ? null : note,
          autoRunOn: _autoRunOn.value.isEmpty ? null : _autoRunOn.value,
        );
        if (widget.snippet != null) {
          Pros.snippet.update(widget.snippet!, snippet);
        } else {
          Pros.snippet.add(snippet);
        }
        context.pop();
      },
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal:13),
      children: [
        _buildImport(),
        Input(
          autoFocus: true,
          controller: _nameController,
          type: TextInputType.text,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_scriptNode),
          label: l10n.name,
          icon: Icons.info,
          suggestion: true,
        ),
        Input(
          controller: _noteController,
          minLines: 3,
          maxLines: 3,
          type: TextInputType.multiline,
          label: l10n.note,
          icon: Icons.note,
          suggestion: true,
        ),
        TagTile(tags: _tags, allTags: Pros.snippet.tags.value).cardx,
        Input(
          controller: _scriptController,
          node: _scriptNode,
          minLines: 3,
          maxLines: 10,
          type: TextInputType.multiline,
          label: l10n.snippet,
          icon: Icons.code,
          suggestion: false,
        ),
        _buildAutoRunOn(),
        _buildTip(),
      ],
    );
  }

  Widget _buildAutoRunOn() {
    return CardX(
      child: ValBuilder(
        listenable: _autoRunOn,
        builder: (vals) {
          final subtitle = vals.isEmpty
              ? null
              : vals
                  .map((e) => Pros.server.pick(id: e)?.spi.name ?? e)
                  .join(', ');
          return ListTile(
            leading: const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Icon(Icons.settings_remote, size: 19),
            ),
            title: Text(l10n.autoRun),
            trailing: const Icon(Icons.keyboard_arrow_right),
            subtitle: subtitle == null
                ? null
                : Text(
                    subtitle,
                    maxLines: 1,
                    style: UIs.textGrey,
                    overflow: TextOverflow.ellipsis,
                  ),
            onTap: () async {
              vals.removeWhere((e) => !Pros.server.serverOrder.contains(e));
              final serverIds = await context.showPickDialog(
                title: l10n.autoRun,
                items: Pros.server.serverOrder,
                name: (e) => Pros.server.pick(id: e)?.spi.name ?? e,
                initial: vals,
                clearable: true,
              );
              if (serverIds != null) {
                _autoRunOn.value = serverIds;
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildImport() {
    return Btn.tile(
      text: l10n.import,
      icon: const Icon(BoxIcons.bx_import),
      onTap: (c) async {
        final data = await c.showImportDialog(
          title: l10n.snippet,
          modelDef: Snippet.example.toJson(),
        );
        if (data == null) return;
        final str = String.fromCharCodes(data);
        final list = json.decode(str) as List;
        if (list.isEmpty) return;
        final snippets = <Snippet>[];
        final errs = <String>[];
        for (final item in list) {
          try {
            final snippet = Snippet.fromJson(item);
            snippets.add(snippet);
          } catch (e) {
            errs.add(e.toString());
          }
        }
        if (snippets.isEmpty) {
          c.showSnackBar(libL10n.empty);
          return;
        }
        if (errs.isNotEmpty) {
          c.showRoundDialog(
            title: l10n.error,
            child: SingleChildScrollView(child: Text(errs.join('\n'))),
          );
          return;
        }
        final snippetNames = snippets.map((e) => e.name).join(', ');
        c.showRoundDialog(
          title: l10n.attention,
          child: SingleChildScrollView(
            child: Text(l10n.askContinue('${l10n.import} [$snippetNames]')),
          ),
          actions: Btn.ok(
            onTap: (c) {
              for (final snippet in snippets) {
                Pros.snippet.add(snippet);
              }
              c.pop();
              context.pop();
            },
          ).toList,
        );
      },
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _buildTip() {
    return CardX(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: SimpleMarkdown(
          data: '''
📌 ${l10n.supportFmtArgs}\n
${Snippet.fmtArgs.keys.map((e) => '`$e`').join(', ')}\n

${Snippet.fmtTermKeys.keys.map((e) => '`$e+?}`').join(', ')}\n
${l10n.forExample}: 
- `\${ctrl+c}` (Control + C)
- `\${ctrl+b}d` (Tmux Detach)
''',
          styleSheet: MarkdownStyleSheet(
            codeblockDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final snippet = widget.snippet;
    if (snippet != null) {
      _nameController.text = snippet.name;
      _scriptController.text = snippet.script;
      if (snippet.note != null) {
        _noteController.text = snippet.note!;
      }

      if (snippet.tags != null) {
        _tags.value = snippet.tags!.toSet();
      }

      if (snippet.autoRunOn != null) {
        _autoRunOn.value = snippet.autoRunOn!;
      }
    }
  }
}
