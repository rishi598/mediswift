// lib/views/appointment/appointment.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mediswiftmobile/core/constants/colors.dart';
import 'package:mediswiftmobile/views/patient/payment/payment_screen.dart';
import 'package:mediswiftmobile/widgets/bottom_nav_bar.dart';

class AppointmentPage extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const AppointmentPage({super.key, required this.doctor});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime now = DateTime.now();
  List<DateTime> weekDates = []; // Mon -> Sat DateTimes
  String? selectedDateIso; // ISO yyyy-MM-dd
  String? selectedTime;
  Map<String, Set<String>> bookedSlotsByDate = {};
  Set<String> doctorBlockedSlots = {};
  Set<String> fullyBlockedDates = {};
  Map<String, Map<String, String>> _slotStatusByDate =
      {}; // {date: {time: status}}

  @override
  void initState() {
    super.initState();
    _prepareWeekRange();
    _loadBookedAppointments();
    _loadDoctorBlockedSlots();

    // ✅ Auto-select Monday (first day in weekDates)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (weekDates.isNotEmpty) {
        // Find the first non-past date (today or future)
        final DateTime today = DateTime.now();
        DateTime? firstActive;

        for (var dt in weekDates) {
          final isPast = dt.isBefore(
            DateTime(today.year, today.month, today.day),
          );
          if (!isPast) {
            firstActive = dt;
            break;
          }
        }

        // If all are past (edge case), just take the last available
        firstActive ??= weekDates.last;

        setState(() {
          selectedDateIso = DateFormat('yyyy-MM-dd').format(firstActive!);
        });
      }
    });
  }

  void _prepareWeekRange() {
    DateTime today = DateTime.now();

    // Find this week's Monday
    DateTime monday = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );

    if (today.weekday == DateTime.sunday) {
      monday = monday.add(const Duration(days: 7));
    }

    // Generate Mon–Sat and filter based on availableDays
    final allDays = List.generate(
      6,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );

    final List<String> availableDays =
        (widget.doctor['availableDays'] ?? [])
            .map<String>((d) => d.toString().toLowerCase())
            .toList();

    weekDates =
        allDays.where((dt) {
          final dayName = DateFormat('EEEE').format(dt).toLowerCase();
          return availableDays.contains(dayName);
        }).toList();

    debugPrint(
      "✅ Doctor ${widget.doctor['doctorName']} working days this week: ${weekDates.map((e) => DateFormat('EEEE').format(e)).toList()}",
    );
  }

  Future<void> _loadDoctorBlockedSlots() async {
    final List<String> s = List<String>.from(
      widget.doctor['selectedTimeSlots'] ?? [],
    );
    doctorBlockedSlots = s.toSet();
  }

  Future<void> _loadBookedAppointments() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/appointment.json',
      );
      final List<dynamic> data = json.decode(response);

      final Map<String, Set<String>> bookedMap = {};
      final Map<String, Map<String, String>> statusMap = {};

      for (var ap in data) {
        final docName =
            (ap['doctorName'] ?? '').toString().trim().toLowerCase();
        final currentDoctorName =
            (widget.doctor['doctorName'] ?? '').toString().trim().toLowerCase();

        if (docName == currentDoctorName) {
          // Normalize date
          String dateIso;
          try {
            final parsed = DateTime.parse(ap['selectedDate']);
            dateIso = DateFormat('yyyy-MM-dd').format(parsed);
          } catch (_) {
            dateIso = ap['selectedDate'];
          }

          // 🕒 Normalize and force proper AM/PM format
          String rawTime = ap['selectedTime'].toString().trim();
          String timeStr = _normalizeTime(rawTime);

          // ✅ Add to maps
          bookedMap.putIfAbsent(dateIso, () => <String>{}).add(timeStr);
          final status = (ap['status'] ?? 'none').toString().toLowerCase();
          statusMap.putIfAbsent(dateIso, () => {})[timeStr] = status;

          debugPrint("🔹 Added slot for $dateIso → $timeStr → $status");
        }
      }

      setState(() {
        bookedSlotsByDate = bookedMap;
        _slotStatusByDate = statusMap;
      });

      debugPrint("✅ Final status map: $_slotStatusByDate");
    } catch (e) {
      debugPrint('❌ Error loading appointment.json: $e');
    }
  }

  String _normalizeTime(String time) {
    try {
      // Already has AM/PM
      if (time.toLowerCase().contains('am') ||
          time.toLowerCase().contains('pm')) {
        final parsed = DateFormat.jm('en_US').parse(time);
        return DateFormat(
          'h:mm a',
          'en_US',
        ).format(parsed).replaceAll('\u202f', ' ').trim();
      }

      // If it's 24-hour like 17:30 or 05:30
      final parsed = DateFormat('H:mm').parse(time);
      return DateFormat(
        'h:mm a',
        'en_US',
      ).format(parsed).replaceAll('\u202f', ' ').trim();
    } catch (_) {
      return time.trim();
    }
  }

  bool _isSameTimeSlot(String slot1, String slot2) {
    try {
      final t1 = DateFormat('h:mm a').parse(_normalizeTime(slot1));
      final t2 = DateFormat('h:mm a').parse(_normalizeTime(slot2));
      return t1.hour == t2.hour && t1.minute == t2.minute;
    } catch (_) {
      return false;
    }
  }

  List<String> _generateTimeSlots() {
    // Only show doctor’s selectedTimeSlots as bookable
    final List<String> selectedSlots = List<String>.from(
      widget.doctor['selectedTimeSlots'] ?? [],
    );

    // Ensure consistent time formatting
    return selectedSlots
        .map((time) => _normalizeTime(time))
        .toList()
        .toSet()
        .toList()
      ..sort((a, b) {
        try {
          return DateFormat(
            'h:mm a',
          ).parse(a).compareTo(DateFormat('h:mm a').parse(b));
        } catch (_) {
          return a.compareTo(b);
        }
      });
  }

  bool _isDateBeforeToday(DateTime date) {
    final DateTime today = DateTime.now();
    final DateTime todayOnly = DateTime(today.year, today.month, today.day);
    final DateTime target = DateTime(date.year, date.month, date.day);
    return target.isBefore(todayOnly);
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    debugPrint("Doctor data: ${widget.doctor}");
    final timeSlots = _generateTimeSlots();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Appointment Slots",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🩺 Doctor Header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(
                        'assets/images/default_doctor.png',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor['doctorName'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor['specialization'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            doctor['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Consultation Fee: ₹${doctor['cost'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),

                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.chat_bubble_outline,
                                  color: AppColors.primaryGreen,
                                ),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.call_outlined,
                                  color: AppColors.primaryGreen,
                                ),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.videocam_outlined,
                                  color: AppColors.primaryGreen,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ⭐ Star Rating & Recommend Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: List.generate(5, (i) {
                      final starCount = (doctor['starCount'] ?? 0).toDouble();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            doctor['starCount'] = i + 1;
                          });
                        },
                        child: Icon(
                          i < starCount.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.primaryGreen,
                          size: 22,
                        ),
                      );
                    }),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        if (doctor['isRecommended'] == true) {
                          doctor['isRecommended'] = false;
                          doctor['recommendationCount'] =
                              (doctor['recommendationCount'] ?? 0) - 1;
                        } else {
                          doctor['isRecommended'] = true;
                          doctor['recommendationCount'] =
                              (doctor['recommendationCount'] ?? 0) + 1;
                        }
                      });
                    },
                    icon: Icon(
                      doctor['isRecommended'] == true
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Recommend (${doctor['recommendationCount'] ?? 0})",
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 📤 Share Button
                  IconButton(
                    onPressed: () {
                      final String message =
                          "👨‍⚕️ ${doctor['doctorName']} - ${doctor['specialization']}\n"
                          "🏥 ${doctor['clinicName']}\n"
                          "📍 ${doctor['clinicAddress']}\n\n"
                          "Highly recommended specialist available for appointments via Fortress of Care App 💚";

                      // Share.share(message, subject: 'Doctor Recommendation');
                    },
                    icon: const Icon(
                      Icons.share_outlined,
                      color: AppColors.primaryGreen,
                    ),
                    tooltip: "Share Doctor Profile",
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 🧩 Reviews Expansion Section
              if (doctor['reviews'] != null &&
                  (doctor['reviews'] as List).isNotEmpty)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "⭐ ${doctor['starCount'] ?? 0} (${doctor['reviews'].length} Reviews)",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      // const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                  children: [
                    ...List.generate(
                      (doctor['reviews'] as List).length > 3
                          ? 3
                          : (doctor['reviews'] as List).length,
                      (i) {
                        final review = doctor['reviews'][i];
                        return ListTile(
                          leading: const Icon(
                            Icons.comment,
                            color: AppColors.primaryGreen,
                          ),
                          title: Text(
                            '"${review['text']}"',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            '- ${review['user']}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                    if ((doctor['reviews'] as List).length > 3)
                      TextButton(
                        onPressed: () {
                          // Later can show full review list page
                        },
                        child: const Text(
                          'View all reviews',
                          style: TextStyle(color: AppColors.primaryGreen),
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 22),

              // 🗓 Date Selector
              const Text(
                "Select date",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: weekDates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final dt = weekDates[idx];
                    final iso = DateFormat('yyyy-MM-dd').format(dt);
                    final weekdayShort = DateFormat('E').format(dt);
                    final dayNum = dt.day;
                    final isSelected = selectedDateIso == iso;

                    final isPastDate = _isDateBeforeToday(dt);

                    return GestureDetector(
                      onTap:
                          isPastDate
                              ? null // disable tapping past dates
                              : () {
                                setState(() {
                                  selectedDateIso = iso;
                                  selectedTime = null;
                                });
                              },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 88,
                        decoration: BoxDecoration(
                          color:
                              isPastDate
                                  ? Colors.grey.shade200
                                  : (isSelected
                                      ? AppColors.primaryGreen
                                      : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                isPastDate
                                    ? Colors.grey.shade300
                                    : (isSelected
                                        ? AppColors.primaryGreen
                                        : Colors.grey.shade300),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(dt),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color:
                                    isPastDate
                                        ? Colors.grey
                                        : (isSelected
                                            ? Colors.white
                                            : Colors.black87),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${dt.day}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color:
                                    isPastDate
                                        ? Colors.grey
                                        : (isSelected
                                            ? Colors.white
                                            : Colors.black87),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM').format(dt),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color:
                                    isPastDate
                                        ? Colors.grey
                                        : (isSelected
                                            ? Colors.white70
                                            : Colors.grey),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // ⏰ Time Slots
              if (selectedDateIso != null) ...[
                const Text(
                  "Available time slots",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      _generateTimeSlots().map((slot) {
                        final String dateKey = selectedDateIso ?? "";
                        String slotStatus = "none";
                        if (_slotStatusByDate.containsKey(selectedDateIso)) {
                          _slotStatusByDate[selectedDateIso]!.forEach((
                            bookedSlot,
                            status,
                          ) {
                            if (_isSameTimeSlot(bookedSlot, slot)) {
                              slotStatus = status;
                            }
                          });
                        }

                        debugPrint(
                          "🧩 Slot Debug → Doctor: ${widget.doctor['doctorName']} | Date: $dateKey | Slot: $slot | Status: $slotStatus",
                        );

                        final now = DateTime.now();
                        final selectedDate = DateFormat(
                          'yyyy-MM-dd',
                        ).parse(selectedDateIso!);
                        bool isPastTime = false;

                        try {
                          final slotTime = DateFormat('h:mm a').parse(slot);
                          final slotDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            slotTime.hour,
                            slotTime.minute,
                          );
                          if (selectedDate.year == now.year &&
                              selectedDate.month == now.month &&
                              selectedDate.day == now.day) {
                            isPastTime = !slotDateTime.isAfter(now);
                          }
                        } catch (_) {
                          isPastTime = false;
                        }

                        bool isDisabled = false;
                        Color bgColor = Colors.white;
                        Color borderColor = Colors.grey.shade300;
                        Color textColor = Colors.black87;

                        // 🟠 Status-based coloring & disable logic
                        if (slotStatus == "pending") {
                          bgColor = Colors.orange.shade100;
                          borderColor = Colors.orange;
                          textColor = Colors.orange.shade700;
                          isDisabled = true;
                        } else if (slotStatus == "accepted") {
                          bgColor = Colors.grey.shade200;
                          borderColor = Colors.grey;
                          textColor = Colors.grey;
                          isDisabled = true;
                        } else if (slotStatus == "rejected" ||
                            slotStatus == "completed") {
                          bgColor = Colors.white;
                          borderColor = Colors.grey.shade300;
                          textColor = Colors.black87;
                          isDisabled = isPastTime; // only enable if future slot
                        } else {
                          // Normal available slot logic
                          isDisabled = isPastTime;
                          bgColor =
                              isDisabled
                                  ? Colors.grey.shade200
                                  : (selectedTime == slot
                                      ? AppColors.primaryGreen
                                      : Colors.white);
                          borderColor =
                              isDisabled
                                  ? Colors.grey.shade300
                                  : (selectedTime == slot
                                      ? AppColors.primaryGreen
                                      : Colors.grey.shade300);
                          textColor =
                              isDisabled
                                  ? Colors.grey
                                  : (selectedTime == slot
                                      ? Colors.white
                                      : Colors.black87);
                        }

                        return GestureDetector(
                          onTap:
                              isDisabled
                                  ? null
                                  : () {
                                    setState(() {
                                      selectedTime = slot;
                                    });
                                  },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 30),
              ],

              // ✅ Book Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      (selectedDateIso != null && selectedTime != null)
                          ? () {
                            // 🟢 Build appointment data to send to PaymentScreen
                            final appointmentData = {
                              'doctorName': doctor['doctorName'],
                              'specialization': doctor['specialization'],
                              'selectedDate': selectedDateIso,
                              'selectedTime': selectedTime,
                              'clinic':
                                  doctor['clinicName'] ??
                                  'Fortress of Care Multispeciality Hospital',
                              'cost': doctor['cost'] ?? 0,
                            };

                            // 🟢 Navigate to PaymentScreen
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(
                                  milliseconds: 400,
                                ),
                                pageBuilder:
                                    (_, animation, __) => FadeTransition(
                                      opacity: animation,
                                      child: PaymentScreen(
                                        appointmentData: appointmentData,
                                      ),
                                    ),
                              ),
                            );
                          }
                          : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
