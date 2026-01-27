import 'package:flutter/material.dart';
import '../../data/repositories/order_repository.dart';

/// Form for collecting shipping address
class AddressForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ValueChanged<ShippingAddress> onAddressChanged;

  const AddressForm({
    super.key,
    required this.formKey,
    required this.onAddressChanged,
  });

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _nameController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postcodeController = TextEditingController();
  String _selectedCountry = 'US';

  static const List<Map<String, String>> _countries = [
    {'code': 'US', 'name': 'United States'},
    {'code': 'GB', 'name': 'United Kingdom'},
    {'code': 'CA', 'name': 'Canada'},
    {'code': 'AU', 'name': 'Australia'},
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'FR', 'name': 'France'},
    {'code': 'NL', 'name': 'Netherlands'},
    {'code': 'ES', 'name': 'Spain'},
    {'code': 'IT', 'name': 'Italy'},
    {'code': 'SE', 'name': 'Sweden'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  void _updateAddress() {
    widget.onAddressChanged(ShippingAddress(
      name: _nameController.text.trim(),
      line1: _line1Controller.text.trim(),
      line2: _line2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postcode: _postcodeController.text.trim(),
      country: _selectedCountry,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Full Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            onChanged: (_) => _updateAddress(),
          ),
          const SizedBox(height: 12),
          // Address Line 1
          TextFormField(
            controller: _line1Controller,
            decoration: const InputDecoration(
              labelText: 'Address Line 1',
              hintText: 'Street address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.home_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
            onChanged: (_) => _updateAddress(),
          ),
          const SizedBox(height: 12),
          // Address Line 2
          TextFormField(
            controller: _line2Controller,
            decoration: const InputDecoration(
              labelText: 'Address Line 2 (Optional)',
              hintText: 'Apartment, suite, unit, etc.',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.apartment_outlined),
            ),
            onChanged: (_) => _updateAddress(),
          ),
          const SizedBox(height: 12),
          // City and State row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateAddress(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State/Province',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateAddress(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Postcode and Country row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _postcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Postcode/ZIP',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateAddress(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                  items: _countries.map((country) {
                    return DropdownMenuItem(
                      value: country['code'],
                      child: Text(country['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCountry = value;
                      });
                      _updateAddress();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
