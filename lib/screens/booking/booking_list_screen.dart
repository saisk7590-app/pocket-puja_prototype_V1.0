import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/booking/booking_card.dart';
import '../../data/booking/booking_data.dart';
import 'booking_detail_screen.dart';
import 'booking_flow_screen.dart';
import 'rating_screen.dart';
import '../../widgets/common/nav_constants.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});
  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  int _tab = 0;
  final _tabs = ['All', 'Active', 'Completed', 'Cancelled'];

  String _stepperStatus(String status) {
    switch (status) {
      case 'COMPLETED':
      case 'RATED':
        return 'DONE';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BookingData> list;
    switch (_tab) {
      case 0:
        list = [...activeBookings, ...completedBookings, ...cancelledBookings];
        break;
      case 1:
        list = activeBookings;
        break;
      case 2:
        list = completedBookings;
        break;
      default:
        list = cancelledBookings;
    }

    return GlassScaffold(
      showBack: false,
      title: 'My Bookings',
      floatingActionButton: Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, extraFloatingElementPadding(context, kFabHeight)),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const BookingFlowScreen())),
          icon: const Icon(Icons.add),
          label: const Text(
            'Book a Pooja',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: _tab == i
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _tab == i ? AppColors.primary : Colors.white24,
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      color: _tab == i ? AppColors.primary : Colors.white60,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 56,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No bookings yet',
                          style: TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      tabBottomPadding(context),
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: BookingCard(
                        booking: list[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookingDetailScreen(
                              poojaName: list[i].poojaName,
                              bookingId: list[i].ref,
                              status: _stepperStatus(list[i].status),
                              pandit: list[i].pandit,
                            ),
                          ),
                        ),
                        onRate:
                            (list[i].status == 'COMPLETED' ||
                                list[i].status == 'DONE')
                            ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RatingScreen(
                                    bookingRef: list[i].ref,
                                    poojaName: list[i].poojaName,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
