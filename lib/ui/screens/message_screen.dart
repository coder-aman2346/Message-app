import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/messages_provider.dart';

import '../../helper/utils.dart';

import '../../models/conversation.dart';
import '../../models/message.dart';

import '../../helper/enums/convo_action_enum.dart';

import '../widgets/shared/bottom_message_bar.dart';
import '../widgets/custom_link_preview.dart';

// ignore: must_be_immutable
class MessageScreen extends StatelessWidget {
  final double _splashRadius = 21;
  ScrollController _sController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final convo = Provider.of<Conversation>(context);
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white.withOpacity(0.9),
        leading: IconButton(
          splashRadius: _splashRadius,
          onPressed: () {
            if (convo.messages.isEmpty) {
              if (convo.isGroup) {
                context.read<MessagesProvider>().deleteGroup(convo);
              } else
                context.read<MessagesProvider>().deleteConversation(convo);
            }
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        iconTheme: IconThemeData(color: Colors.grey[800]),
        title: Text(
          convo.sender.name,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          if (!convo.isSpam)
            IconButton(
              splashRadius: _splashRadius,
              onPressed: () {},
              icon: Icon(Icons.call),
            ),
          IconButton(
            splashRadius: _splashRadius,
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
          PopupMenuButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onSelected: (ConversationActions filter) => filter.actionOnConversation(context, convo),
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              if (!convo.sender.isAdded && !convo.isGroup)
                PopupMenuItem(
                  child: Text("Add contact"),
                  value: ConversationActions.ADD_CONTACT,
                ),
              PopupMenuItem(
                child: Text("Details"),
                value: ConversationActions.DETAILS,
              ),
              if (!convo.isSpam)
                PopupMenuItem(
                  child: Text(convo.isArchived ? "Unarchive" : "Archive"),
                  value: ConversationActions.ARCHIVE,
                ),
              PopupMenuItem(
                child: Text("Delete"),
                value: ConversationActions.DELETE,
              ),
              PopupMenuItem(
                child: Text("Help & feedback"),
                value: ConversationActions.HELP,
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          //MessagesList
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: MessagesList(sController: _sController, avClr: convo.sender.avClr),
          ),

          //Bottom Text Input Bar
          if (!convo.isSpam)
            Positioned(
              bottom: 0,
              child: BottomMessageBar(sController: _sController),
            ),

          //Unspam
          if (convo.isSpam)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Card(
                margin: EdgeInsets.zero,
                color: Colors.grey[100].withOpacity(0.93),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 18, 15, 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //Icon and text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.block,
                            size: 28,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 30),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Blocked",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "To move this conversation out of \"Spam & blocked\" and get messages again, unblock ${convo.sender.name}",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      //Unblock button
                      TextButton(
                        onPressed: () {

                        },
                        style: TextButton.styleFrom(
                          splashFactory: InkRipple.splashFactory,
                          //splashColor: Theme.of(context).primaryColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        ),
                        child: Text(
                          "Unblock",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MessagesList extends StatefulWidget {
  final ScrollController sController;
  final avClr;

  const MessagesList({Key key, @required this.sController, @required this.avClr}) : super(key: key);

  @override
  _MessagesListState createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.sController.jumpTo(widget.sController.position.maxScrollExtent));
    super.initState();
  }

  @override
  void dispose() {
    widget.sController.dispose();
    super.dispose();
  }

  void disableKeyboard() {
    setState(() {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final convo = Provider.of<Conversation>(context, listen: false);
    return GestureDetector(
      onTap: disableKeyboard,
      child: Scrollbar(
        isAlwaysShown: true,
        controller: widget.sController,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overScroll) {
            overScroll.disallowGlow();
            return false;
          },
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            controller: widget.sController,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: convo.messages.length,
            itemBuilder: (ctx, i) {
              if (i == convo.messages.length - 1)
                return Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: MessageListItem(
                    isSpam: convo.isSpam,
                    contact: convo.sender,
                    msg: convo.messages[i],
                    avClr: widget.avClr,
                  ),
                );
              return MessageListItem(
                isSpam: convo.isSpam,
                contact: convo.sender,
                msg: convo.messages[i],
                avClr: widget.avClr,
              );
            },
          ),
        ),
      ),
    );
  }
}

class MessageListItem extends StatefulWidget {
  final isSpam, contact;
  final Message msg;
  final Color avClr;

  const MessageListItem({
    Key key,
    @required this.isSpam,
    @required this.avClr,
    @required this.contact,
    @required this.msg,
  }) : super(key: key);

  @override
  _MessageListItemState createState() => _MessageListItemState();
}

class _MessageListItemState extends State<MessageListItem> with SingleTickerProviderStateMixin {
  TapGestureRecognizer _recognizer;

  bool showDate = false;

  bool get isPreview => widget.msg.hasPreview;

  bool get isMyMessage => widget.msg.isMyMessage;

  DateTime get messageDate => widget.msg.datetime;

  Widget buildDate({@required bool convoDate}) {
    final msgDaysAgo = DateTime.now().difference(messageDate).inDays;
    String date = '';
    if (convoDate) {
      if (msgDaysAgo == 0)
        return SizedBox.shrink();
      else if (msgDaysAgo > 0 && msgDaysAgo <= 6)
        date = DateFormat(DateFormat.ABBR_WEEKDAY).format(messageDate);
      else if (msgDaysAgo > 6 && msgDaysAgo <= 365)
        date = DateFormat("MMM dd").format(messageDate);
      else
        date = DateFormat("dd/MM/yy").format(messageDate);
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 14, 0, 10),
        child: Text(
          date + " - " + DateFormat('h:mm a').format(messageDate),
          style: TextStyle(
            fontSize: 11,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      if (msgDaysAgo > 0 && msgDaysAgo <= 6)
        date = DateFormat(DateFormat.ABBR_WEEKDAY).format(messageDate) + " - ";
      else if (msgDaysAgo > 6 && msgDaysAgo <= 365)
        date = DateFormat("MMM dd").format(messageDate) + " - ";
      else if (msgDaysAgo > 365) date = DateFormat("dd/MM/yy").format(messageDate) + " - ";
      return Text(
        date + DateFormat('h:mm a').format(messageDate),
        style: TextStyle(
          fontSize: 11,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  Widget buildPreviewMessage() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Animated Date
          buildDate(convoDate: true),

          SizedBox(height: 7),

          //Text Message
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              setState(() {
                showDate = !showDate;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isMyMessage ? Utils.myMessageColor : Utils.greyColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: RichText(
                    text: TextSpan(
                      children: getMessageSpans(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          //Preview
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              border: Border.all(
                color: Utils.greyColor,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Center(
              child: CustomLinkPreview(previewPath: widget.msg.previewPath),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> getMessageSpans(){
    return Utils.splitMessageComponents(widget.msg.body).map((s) {
      return (s == '\$url\$')
          ? TextSpan(
        style: TextStyle(
          decoration: TextDecoration.underline,
          fontSize: 16,
          height: 1.3,
          color: isMyMessage ? Utils.myMessageTextColor : Colors.grey[900],
        ),
        text: widget.msg.previewPath,
        recognizer: _recognizer
          ..onTap = () async => Utils.launchURL(widget.msg.previewPath),
      )
          : TextSpan(
        text: s,
        style: TextStyle(
          fontSize: 16,
          height: 1.3,
          color: isMyMessage ? Utils.myMessageTextColor : Colors.grey[900],
        ),
      );
    }).toList();
  }

  Widget buildTextMessage() {
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Animated Date
          buildDate(convoDate: true),

          SizedBox(height: 7),

          //Text
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              setState(() {
                showDate = !showDate;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isMyMessage ? Utils.myMessageColor : Utils.greyColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Text(
                  widget.msg.body,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    color: isMyMessage ? Utils.myMessageTextColor : Colors.grey[900],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMyMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: 8),
              isPreview ? buildPreviewMessage() : buildTextMessage(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3, right: 10),
            child: AnimatedSize(
              vsync: this,
              curve: Curves.decelerate,
              duration: Duration(milliseconds: 200),
              child: showDate ? buildDate(convoDate: false) : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOthersMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              widget.isSpam
                  ? Icon(
                      Icons.block,
                      color: Colors.grey[700],
                    )
                  : CircleAvatar(
                      radius: 18.5,
                      backgroundColor: widget.avClr,
                      child: widget.contact.isAdded
                          ? Text(
                              widget.contact.name.substring(0, 1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
              SizedBox(width: 8),
              isPreview ? buildPreviewMessage() : buildTextMessage(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 55),
            child: AnimatedSize(
              vsync: this,
              curve: Curves.decelerate,
              duration: Duration(milliseconds: 200),
              child: showDate ? buildDate(convoDate: false) : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  initState() {
    super.initState();
    _recognizer = TapGestureRecognizer();
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isMyMessage ? buildMyMessage() : buildOthersMessage();
  }
}
