import 'package:group/common/navigator/app_navigator.dart';
import 'package:group/common/ui/common/custom_text_field.dart';
import 'package:group/common/ui/widgets/page_error_widget.dart';
import 'package:group/common/ui/widgets/page_loading_indicator.dart';
import 'package:group/features/addresses/data/repositories/modals/address_model.dart';
import 'package:group/features/addresses/edit/bloc/address_edit_bloc.dart';
import 'package:group/features/addresses/modals/search_address/ui/search_address_page.dart';
import 'package:group/features/addresses/modals/select_city/select_city_modal.dart';
import 'package:group/generated/assets.dart';
import 'package:group/packages/core/forms/validators_set.dart';
import 'package:group/packages/ui_kit/colors.dart';
import 'package:group/packages/ui_kit/components/buttons/elevated_button.dart';
import 'package:group/packages/ui_kit/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AddressEditBody extends StatefulWidget {
  final int id;

  const AddressEditBody({required this.id, super.key});

  @override
  State<AddressEditBody> createState() => _AddressEditState();
}

class _AddressEditState extends State<AddressEditBody> {
  final _cityController = FormControl<String>(
    validators: ValidatorSets.city.validators,
  );
  final _addressController = FormControl<String>(
    validators: ValidatorSets.address.validators,
  );
  final _entranceController = FormControl<String>(
    validators: ValidatorSets.entrance.validators,
  );
  final _intercomController = FormControl<String>(
    validators: ValidatorSets.intercom.validators,
  );
  final _apartmentController = FormControl<String>(
    validators: ValidatorSets.apartment.validators,
  );
  final _floorController = FormControl<String>(
    validators: ValidatorSets.floor.validators,
  );
  final _commentController = FormControl<String>();

  bool _isFormReady = false;
  int _selectedCityId = 0;
  bool _isAddressChanged = false;
  double? lat;
  double? long;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressEditBloc, AddressEditState>(
      listener: _addressEditBlocListener,
      builder:
          (context, state) => state.maybeMap(
            loading: (_) => const PageLoadingIndicator(),
            error:
                (_) => PageErrorWidget(
                  refresh:
                      () => BlocProvider.of<AddressEditBloc>(
                        context,
                      ).add(AddressEditEvent.fetchRequested(id: widget.id)),
                ),
            success:
                (state) => SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      CustomTextField(
                        readOnly: true,
                        controller: _cityController,
                        labelText: 'Город',
                        suffixIcon: SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: SvgPicture.asset(
                              Assets.iconsArrowRight,
                              semanticsLabel: 'arrow right',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                        onTap: (_) async {
                          final int? cityId = await AppNavigator.showModal(
                            context: context,
                            child: SelectCityModal(cities: state.cities),
                          );

                          if (cityId == null) {
                            return;
                          }

                          _cityController.value =
                              state.cities
                                  .where((city) => city.id == cityId)
                                  .first
                                  .title;

                          setState(() {
                            _selectedCityId = cityId;
                            _isFormReady = _getFormReadyStatus();
                            _isAddressChanged = true;
                          });
                        },
                      ),
                      if (_selectedCityId != 0)
                        CustomTextField(
                          readOnly: true,
                          controller: _addressController,
                          labelText: 'Адрес',
                          suffixIcon: SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Улица, дом',
                                  style: ZyxTextStyles.text3.withColor(
                                    ZyxColors.textGrey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Center(
                                    child: SvgPicture.asset(
                                      Assets.iconsArrowRight,
                                      semanticsLabel: 'arrow right',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                          onTap: (_) async {
                            final result = await AppNavigator.showModal<
                              ({String? address, double? lat, double? long})
                            >(
                              context: context,
                              child: SearchAddressPage(
                                city: _cityController.value!,
                              ),
                            );

                            if (result?.address == null ||
                                result?.address?.isEmpty == true) {
                              return;
                            }

                            _addressController.value = result?.address;

                            setState(() {
                              lat = result?.lat;
                              long = result?.long;
                              _isFormReady = _getFormReadyStatus();
                              _isAddressChanged = true;
                            });
                          },
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _entranceController,
                              keyboardType: TextInputType.number,
                              labelText: 'Подъезд',
                              onChanged: (_) {
                                setState(() {
                                  _isFormReady = _getFormReadyStatus();
                                  _isAddressChanged = true;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _intercomController,
                              keyboardType: TextInputType.number,
                              labelText: 'Домофон',
                              onChanged: (_) {
                                setState(() {
                                  _isFormReady = _getFormReadyStatus();
                                  _isAddressChanged = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _apartmentController,
                              keyboardType: TextInputType.number,
                              labelText: 'Квартира',
                              onChanged: (_) {
                                setState(() {
                                  _isFormReady = _getFormReadyStatus();
                                  _isAddressChanged = true;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _floorController,
                              keyboardType: TextInputType.number,
                              labelText: 'Этаж',
                              onChanged: (_) {
                                setState(() {
                                  _isFormReady = _getFormReadyStatus();
                                  _isAddressChanged = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      CustomTextField(
                        controller: _commentController,
                        labelText: 'Комментарий курьеру',
                        minLines: 3,
                        maxLines: 5,
                        onChanged: (_) {
                          setState(() {
                            _isAddressChanged = true;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      ZyxElevatedButton(
                        text: 'Готово',
                        block: true,
                        onTap:
                            _isFormReady && _isAddressChanged
                                ? () {
                                  BlocProvider.of<AddressEditBloc>(context).add(
                                    AddressEditEvent.saveRequested(
                                      address: AddressModel(
                                        id: widget.id,
                                        addressId: widget.id,
                                        cityId: _selectedCityId,
                                        token: null,
                                        address: _addressController.value,
                                        entrace: _entranceController.value,
                                        intercom: _intercomController.value,
                                        apartment: _apartmentController.value,
                                        floor: _floorController.value,
                                        comment: _commentController.value,
                                        lat: lat.toString(),
                                        long: long.toString(),
                                      ),
                                    ),
                                  );
                                  AppNavigator.pop(context);
                                }
                                : null,
                      ),
                    ],
                  ),
                ),
            orElse: () => const SizedBox(),
          ),
    );
  }

  bool _getFormReadyStatus() {
    final bool isCityReady = _cityController.valid;
    final bool isAddressReady = _addressController.valid;
    final bool isEntranceReady = _entranceController.valid;
    final bool isIntercomReady = _intercomController.valid;
    final bool isApartmentReady = _apartmentController.valid;
    final bool isFloorReady = _floorController.valid;

    return isCityReady && isAddressReady;
  }

  void _addressEditBlocListener(BuildContext context, AddressEditState state) {
    state.mapOrNull(
      success: (state) {
        _cityController.value =
            state.cities
                .where((city) => city.id == state.address.cityId)
                .first
                .title;
        _addressController.value = state.address.address;
        _entranceController.value = state.address.entrace;
        _intercomController.value = state.address.intercom;
        _apartmentController.value = state.address.apartment;
        _floorController.value = state.address.floor;
        _commentController.value = state.address.comment;

        setState(() {
          _selectedCityId = state.address.cityId!;
          _isFormReady = _getFormReadyStatus();
        });
      },
    );
  }
}
