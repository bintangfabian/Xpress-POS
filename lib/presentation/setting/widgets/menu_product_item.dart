// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:xpress/data/models/response/product_response_model.dart';

import '../../../core/components/buttons.dart';
import '../../../core/components/spaces.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/image_utils.dart';

class MenuProductItem extends StatelessWidget {
  final Product data;
  final Function() onTapEdit;
  const MenuProductItem({
    super.key,
    required this.data,
    required this.onTapEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 3, color: AppColors.primaryLight),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          children: buildList(context),
        ));
  }

  List<Widget> buildList(BuildContext context) {
    return [
      Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              child: _buildProductImage(54, 54),
            ),
          ),
        ],
      ),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(),
            Text(
              data.name!,
              style: const TextStyle(
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              data.category?.name ?? '-',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Spacer(),
            Row(
              children: [
                Flexible(
                  child: Button.outlined(
                    onPressed: () {
                      showDialog(
                          context: context,
                          // backgroundColor: AppColors.white,
                          builder: (context) {
                            //container for product detail
                            return AlertDialog(
                              contentPadding: const EdgeInsets.all(16.0),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        data.name!,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                  const SpaceHeight(10.0),
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    child: _buildProductImage(80, 80),
                                  ),
                                  const SpaceHeight(10.0),
                                  Text(
                                    data.category?.name ?? '-',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SpaceHeight(10.0),
                                  Text(
                                    data.price.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SpaceHeight(10.0),
                                  Text(
                                    data.stock.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SpaceHeight(10.0),
                                ],
                              ),
                            );
                          });
                    },
                    label: 'View',
                    fontSize: 12.0,
                    height: 30,
                    borderRadius: 10,
                  ),
                ),
                const SpaceWidth(6.0),
                Flexible(
                  child: Button.outlined(
                    onPressed: onTapEdit,
                    label: 'Edit',
                    fontSize: 12.0,
                    height: 30,
                    borderRadius: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildProductImage(double width, double height) {
    final safeImageUrl = ImageUtils.getSafeImageUrl(data.image);

    if (safeImageUrl == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha((0.3 * 255).round()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.food_bank_outlined,
          size: width * 0.5,
          color: Colors.grey,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: safeImageUrl,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha((0.3 * 255).round()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: SizedBox(
            width: width * 0.3,
            height: height * 0.3,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha((0.3 * 255).round()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.food_bank_outlined,
          size: width * 0.5,
          color: Colors.grey,
        ),
      ),
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}
