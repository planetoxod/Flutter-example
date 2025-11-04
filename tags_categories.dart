import 'package:group/models/parameters_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/data/database/app_database.dart';
import '../../bloc/restaurant_bloc.dart';
import '../../data/repositories/models/category_model.dart';

class TagsCategories extends StatefulWidget {
  final List<CartItem> cartItems;
  final ScrollController titleController;
  final ParametersTags parametersTags;
  final String searchQuery;
  final void Function(int categoryId)? onTapItem;

  const TagsCategories({
    required this.cartItems,
    required this.titleController,
    required this.parametersTags,
    required this.searchQuery,
    required this.onTapItem,
    super.key,
  });

  @override
  State<TagsCategories> createState() => _TagsCategoriesState();
}

class _TagsCategoriesState extends State<TagsCategories> {
  List<double> heights = [];
  List<GlobalKey> keys = [];

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      //print("SchedulerBinding");
      GlobalKey key;
      for (key in keys) {
        final RenderBox box =
            key.currentContext?.findRenderObject() as RenderBox;
        // For size of wiget
        //  Size size = box.size;
        // For position
        final Offset offset = box.localToGlobal(Offset.zero);
        heights.add(offset.dx);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> scrollTitle(int index) async {
      if (heights.length > index) {
        await Future.delayed(const Duration(milliseconds: 100), () async {
          if (widget.parametersTags.scroll) {
            await widget.titleController.animateTo(
              heights[index] - 6,
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
            );
            widget.parametersTags.scroll = false;
          }
        });
      }
    }

    Future<void> changeState() async {
      while (true) {
        await Future.delayed(const Duration(milliseconds: 100), () {
          if (widget.parametersTags.change) {
            setState(() {
              widget.parametersTags.change = false;
            });
          }
        });
      }
    }

    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder:
          (context, state) => state.maybeMap(
            loading: (state) => const SizedBox(),
            error: (state) => const SizedBox(),
            success:
                (state) => SingleChildScrollView(
                  controller: widget.titleController,
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List<Widget>.generate(
                      state.restaurant.categories!.length,
                      (index) {
                        final CategoryModel category =
                            state.restaurant.categories![index];
                        if (widget.searchQuery.isNotEmpty) {
                          final len =
                              category.products!
                                  .where(
                                    (element) =>
                                        element.title!.toLowerCase().contains(
                                          widget.searchQuery.toLowerCase(),
                                        ),
                                  )
                                  .isEmpty;

                          if (len) {
                            return const SizedBox();
                          }
                        }

                        scrollTitle(widget.parametersTags.index);
                        changeState();

                        keys.add(state.categoriesTitleKeys[category.id!]!);

                        return GestureDetector(
                          onTap: () async {
                            widget.onTapItem!(category.id!);
                          },
                          child: Container(
                            key: state.categoriesTitleKeys[category.id!],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color:
                                  widget.parametersTags.selectedCategory ==
                                              category.id ||
                                          widget
                                                      .parametersTags
                                                      .selectedCategory ==
                                                  0 &&
                                              index == 0
                                      ? const Color(0xFFF9F9F9)
                                      : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              shadows:
                                  widget.parametersTags.selectedCategory ==
                                              category.id ||
                                          widget
                                                      .parametersTags
                                                      .selectedCategory ==
                                                  0 &&
                                              index == 0
                                      ? const [
                                        BoxShadow(
                                          color: Color(0x19000000),
                                          blurRadius: 0,
                                          offset: Offset(0, 0),
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Color(0x19000000),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Color(0x16000000),
                                          blurRadius: 10,
                                          offset: Offset(0, 10),
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Color(0x0C000000),
                                          blurRadius: 14,
                                          offset: Offset(0, 23),
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Color(0x02000000),
                                          blurRadius: 17,
                                          offset: Offset(0, 42),
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Color(0x00000000),
                                          blurRadius: 18,
                                          offset: Offset(0, 65),
                                          spreadRadius: 0,
                                        ),
                                      ]
                                      : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  category.title!,
                                  style: const TextStyle(
                                    color: Color(0xFF2B2A29),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            orElse: () {
              return const SizedBox();
            },
          ),
    );
  }
}
