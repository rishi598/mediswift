import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediswiftmobile/core/constants/colors.dart';
import 'package:mediswiftmobile/views/patient/confirmation/confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  const PaymentScreen({super.key, required this.appointmentData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;
  final _upiController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  final List<String> savedUpiIds = ["rishikesh@okaxis", "r2@paytm", "rr@oksbi"];

  final List<Map<String, String>> savedCards = [
    {
      "masked": "**** **** **** 4582",
      "holder": "Rishikesh Ramakrishnan",
      "expiry": "11/26",
    },
    {
      "masked": "**** **** **** 2190",
      "holder": "Rishikesh Ramakrishnan",
      "expiry": "07/25",
    },
  ];

  String? _cardError;
  String? _expiryError;
  String? _cvvError;

  bool _isUpiValid = false;

  // add inside _PaymentScreenState
  bool _isNameMatching(String enteredName, String actualName) {
    final cleanEntered = enteredName.toLowerCase().replaceAll(
      RegExp(r'\s+'),
      '',
    );
    final cleanActual = actualName.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    return cleanEntered == cleanActual;
  }

  // 🔹 Luhn Algorithm – standard credit card validation
  bool _isValidCardNumber(String input) {
    input = input.replaceAll(' ', '');
    if (input.length < 13 || input.length > 19) return false;
    int sum = 0;
    bool alternate = false;
    for (int i = input.length - 1; i >= 0; i--) {
      int n = int.parse(input[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return (sum % 10 == 0);
  }

  // 🔹 Expiry validation with auto-format (MM/YY)
  bool _isValidExpiry(String expiry) {
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) return false;

    final parts = expiry.split('/');
    final int month = int.tryParse(parts[0]) ?? 0;
    final int year = 2000 + (int.tryParse(parts[1]) ?? 0);

    if (month < 1 || month > 12) return false;

    final now = DateTime.now();
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    return lastDayOfMonth.isAfter(DateTime(now.year, now.month, now.day));
  }

  // 🔹 Format card number: 1234567812345678 → 1234 5678 1234 5678
  String _formatCardNumber(String input) {
    input = input.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      buffer.write(input[i]);
      final index = i + 1;
      if (index % 4 == 0 && index != input.length) buffer.write(' ');
    }
    return buffer.toString();
  }

  // 🔹 Simple UPI ID validation logic
  bool _validateUpi(String upi) {
    // Common UPI handles used in India
    final validHandles = [
      'okaxis',
      'okicici',
      'oksbi',
      'okhdfcbank',
      'ybl',
      'paytm',
      'ibl',
      'upi',
      'axl',
      'apl',
    ];

    final pattern = RegExp(r'^[\w.-]+@([\w]+)$');
    final match = pattern.firstMatch(upi);

    if (match == null) return false;

    final handle = match.group(1)?.toLowerCase();
    return validHandles.contains(handle);
  }

  // 🔹 Simple card number check (16 digits)

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointmentData;
    final userFullName =
        (appointment['patientName'] ?? "Rishikesh Ramakrishnan")
            .toLowerCase()
            .trim();

    final doctorName = appointment['doctorName'] ?? "Doctor";
    final specialization = appointment['specialization'] ?? "Specialist";
    final selectedDate =
        appointment['selectedDate'] ?? DateTime.now().toString();
    final selectedTime = appointment['selectedTime'] ?? "10:00 AM";
    final cost = appointment['cost'] ?? 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Payment",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose payment method",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 18),

            // 🧾 Appointment Summary Card
            _buildSummaryCard(
              doctorName,
              specialization,
              selectedDate,
              selectedTime,
              cost,
            ),

            const SizedBox(height: 25),

            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 14),

            // 💰 Payment Options
            _paymentOption(
              title: "UPI Payment",
              subtitle: "Google Pay, PhonePe, Paytm",
              icon: Icons.account_balance_wallet_outlined,
              value: "upi",
            ),
            if (_selectedMethod == "upi") ...[
              if (savedUpiIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 6,
                    bottom: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Saved UPI IDs",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children:
                            savedUpiIds.map((upi) {
                              return ChoiceChip(
                                label: Text(upi),
                                selected: _upiController.text == upi,
                                selectedColor: AppColors.primaryGreen
                                    .withOpacity(0.15),
                                labelStyle: TextStyle(
                                  color:
                                      _upiController.text == upi
                                          ? AppColors.primaryGreen
                                          : Colors.black87,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _upiController.text = upi;
                                      _isUpiValid = _validateUpi(upi);
                                    });
                                  }
                                },
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              _buildUpiField(),
            ],

            const SizedBox(height: 10),
            _paymentOption(
              title: "Debit/Credit Card",
              subtitle: "Visa, Mastercard, Rupay",
              icon: Icons.credit_card_outlined,
              value: "card",
            ),
            if (_selectedMethod == "card") ...[
              if (savedCards.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 6,
                    bottom: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Saved Cards",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Column(
                        children:
                            savedCards.map((card) {
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                leading: const Icon(
                                  Icons.credit_card,
                                  color: AppColors.primaryGreen,
                                ),
                                title: Text(
                                  card['masked']!,
                                  style: const TextStyle(fontFamily: 'Inter'),
                                ),
                                subtitle: Text(
                                  "Exp: ${card['expiry']}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _cardNumberController.text =
                                          card['masked']!;
                                      _cardNameController.text =
                                          card['holder']!;
                                      _expiryController.text = card['expiry']!;
                                    });
                                  },
                                  child: const Text(
                                    "Use",
                                    style: TextStyle(
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              _buildCardForm(userFullName),
            ],

            const SizedBox(height: 10),
            _paymentOption(
              title: "Cash on Appointment",
              subtitle: "Pay directly to the doctor",
              icon: Icons.money_outlined,
              value: "cash",
            ),

            const SizedBox(height: 30),

            // ✅ Confirm Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _selectedMethod == null
                        ? null
                        : () {
                          // 🟢 Simulate payment success
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Payment successful via ${_selectedMethod!.toUpperCase()}',
                              ),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );

                          // 🗓️ Build appointment data with pending status
                          final appointmentData = {
                            ...widget.appointmentData,
                            'modeOfPayment': _selectedMethod,
                            'status': 'pending',
                          };

                          // 📩 Navigate to Confirmation Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ConfirmationScreen(
                                    appointmentData: appointmentData,
                                  ),
                            ),
                          );
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Proceed to Pay",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ⚖️ Terms
            const Center(
              child: Text(
                "By proceeding, you agree to our Terms & Conditions and Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧾 Summary Card
  Widget _buildSummaryCard(
    String doctorName,
    String specialization,
    String date,
    String time,
    int cost,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage('assets/images/default_doctor.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      specialization,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _summaryRow(
            "Date & Time",
            "${DateFormat('MMM d, yyyy').format(DateTime.parse(date))} • $time",
          ),
          const SizedBox(height: 8),
          _summaryRow("Consultation Type", "In-person Visit"),
          const SizedBox(height: 8),
          _summaryRow("Duration", "30 minutes"),
          const Divider(height: 20),
          _summaryRow(
            "Total Amount",
            "₹$cost",
            valueColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _paymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                _selectedMethod == value
                    ? AppColors.primaryGreen
                    : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedMethod,
              activeColor: AppColors.primaryGreen,
              onChanged: (val) => setState(() => _selectedMethod = val),
            ),
          ],
        ),
      ),
    );
  }

  // 🟢 UPI Input Box
  Widget _buildUpiField() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _upiController,
            decoration: InputDecoration(
              labelText: "Enter your UPI ID",
              hintText: "example@okaxis",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primaryGreen),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _isUpiValid = _validateUpi(val.trim());
              });
            },
          ),
          const SizedBox(height: 6),
          Text(
            _upiController.text.isEmpty
                ? ""
                : _isUpiValid
                ? "✅ Valid UPI ID"
                : "❌ Invalid UPI ID",
            style: TextStyle(
              color: _isUpiValid ? Colors.green : Colors.red,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),

          Row(
            children: [
              Checkbox(
                value: true,
                activeColor: AppColors.primaryGreen,
                onChanged: (_) {},
              ),
              const Text(
                "Save this for future payments",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 💳 Card Input Form
  // 💳 Card Input Form
  Widget _buildCardForm(String userFullName) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
      child: Column(
        children: [
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            maxLength: 19,
            decoration: InputDecoration(
              labelText: "Card Number",
              hintText: "1234 5678 9012 3456",
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (val) {
              // Auto-space every 4 digits
              final cleaned = val.replaceAll(' ', '');
              final formatted = _formatCardNumber(cleaned);
              if (formatted != val) {
                _cardNumberController.text = formatted;
                _cardNumberController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _cardNumberController.text.length),
                );
              }
              // validate card number Luhn
              setState(() {
                _cardError =
                    _isValidCardNumber(cleaned) ? null : 'Invalid card number';
              });
            },
          ),
          const SizedBox(height: 10),

          // Cardholder name
          TextField(
            controller: _cardNameController,
            decoration: InputDecoration(
              labelText: "Cardholder Name",
              hintText: "As per card",
              errorText: _cardError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (val) {
              setState(() {
                // basic alphabet check
                if (!RegExp(r'^[A-Za-z ]+$').hasMatch(val.trim())) {
                  _cardError = 'Only alphabets allowed';
                } else if (userFullName.isNotEmpty &&
                    !_isNameMatching(val, userFullName)) {
                  _cardError = 'Name does not match registered user';
                } else {
                  _cardError = null;
                }
              });
            },
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: InputDecoration(
                    labelText: "Expiry (MM/YY)",
                    counterText: "",
                    errorText: _expiryError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (val) {
                    // auto-insert slash
                    String cleaned = val.replaceAll('/', '');
                    if (cleaned.length >= 2) {
                      final m = cleaned.substring(0, 2);
                      final rest =
                          cleaned.length > 2 ? cleaned.substring(2) : '';
                      final formatted =
                          rest.isEmpty
                              ? m
                              : '$m/${rest.substring(0, rest.length > 2 ? 2 : rest.length)}';
                      if (formatted != val) {
                        _expiryController.text = formatted;
                        _expiryController
                            .selection = TextSelection.fromPosition(
                          TextPosition(offset: _expiryController.text.length),
                        );
                      }
                    }
                    setState(() {
                      _expiryError =
                          _isValidExpiry(_expiryController.text)
                              ? null
                              : 'Invalid expiry';
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "CVV",
                    counterText: "",
                    errorText: _cvvError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _cvvError = val.length == 3 ? null : 'Enter 3 digits';
                    });
                  },
                ),
              ),
            ],
          ),

          Row(
            children: [
              Checkbox(
                value: true,
                activeColor: AppColors.primaryGreen,
                onChanged: (_) {},
              ),
              const Text(
                "Save this for future payments",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryGreen,
                  size: 80,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Payment Successful!",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your appointment request has been sent successfully!\n"
                  "Please note: the appointment status is *Pending Approval*.\n\n"
                  "The doctor will review your request and either Accept or Reject it.\n"
                  "You’ll receive a confirmation notification once it’s approved.",

                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close popup
                    Navigator.pop(context); // Go back to appointment page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
