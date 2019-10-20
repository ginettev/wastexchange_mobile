import 'package:flutter/material.dart';
import 'package:wastexchange_mobile/core/utils/app_theme.dart';
import 'package:wastexchange_mobile/core/utils/constants.dart';
import 'package:wastexchange_mobile/core/utils/global_utils.dart';
import 'package:wastexchange_mobile/core/widgets/bottom_action_view_container.dart';
import 'package:wastexchange_mobile/core/widgets/button_view_icon_compact.dart';

class OrderFormTotal extends StatelessWidget {
  // TODO(Sayeed): Should we change this to resemble OrderFormSummaryList constructor
  const OrderFormTotal({this.total, this.itemsCount, this.onPressed});

  final double total;
  final int itemsCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BottomActionViewContainer(
      children: <Widget>[
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('Total: ', style: AppTheme.title),
                      Flexible(
                          child: Text(formattedPrice(total),
                              style: AppTheme.body1,
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  Text(
                    '$itemsCount item' + (itemsCount == 1 ? '' : 's'),
                    style: AppTheme.body2,
                  )
                ]),
            flex: 1),
        ButtonViewIconCompact(
            text: Constants.CONFIRM_BUTTON, onPressed: onPressed)
      ],
    );
  }
}