import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/enums/filters_enum.dart';

import '../../../providers/messages_provider.dart';

import '../../../helper/utils.dart';

class ActionsAppBar extends StatelessWidget {
  final int length;
  final Filters currentFilter;

  const ActionsAppBar({Key key, this.length, this.currentFilter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageManager = Provider.of<MessagesProvider>(context, listen: false);
    return Row(
      children: <Widget>[
        IconButton(
          splashColor: Colors.transparent,
          icon: Icon(
            Icons.close,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: messageManager.clearSelected,
        ),
        Expanded(
          child: Text(
            length.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (currentFilter != Filters.SpamAndBlocked)
          (currentFilter == Filters.Archived)
              ? IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(
                    Icons.unarchive,
                    color:Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    Utils.showFlushBar(
                      context,
                      "${messageManager.selectedConversations.length} conversations unarchived",
                      Icons.unarchive
                    );
                    messageManager.archiveSelected();
                  },
                )
              : IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(
                    Icons.archive,
                    color:Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    Utils.showFlushBar(
                      context,
                      "${messageManager.selectedConversations.length} conversations archived",
                      Icons.archive
                    );
                    messageManager.archiveSelected();
                  },
                ),
        IconButton(
          splashColor: Colors.transparent,
          icon: Icon(
            Icons.delete,
            color:Theme.of(context).primaryColor,
          ),
          onPressed: () {
            Utils.showFlushBar(
              context,
              "${messageManager.selectedConversations.length} conversations deleted",
              Icons.delete
            );
            messageManager.deleteSelected();
          },
        ),
        if (length == 1 && currentFilter != Filters.SpamAndBlocked) ...[
          IconButton(
            splashColor: Colors.transparent,
            icon: Icon(
              Icons.person_add,
              color:Theme.of(context).primaryColor,
            ),
            onPressed: () {
              //messageManager.addContact
            },
          ),
          IconButton(
            splashColor: Colors.transparent,
            icon: Icon(
              Icons.block,
              color:Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Utils.showFlushBar(
                context,
                "${messageManager.selectedConversations.length} conversations marked spam",
                Icons.block
              );
              messageManager.spamSelected();
            },
          ),
        ],
      ],
    );
  }
}
