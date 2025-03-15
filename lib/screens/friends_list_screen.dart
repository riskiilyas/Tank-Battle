import 'package:flutter/material.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({Key? key}) : super(key: key);

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Sample friend data
  final List<Map<String, dynamic>> _friends = [
    {
      'name': 'TankMaster42',
      'status': 'Online',
      'level': 32,
      'avatar': 'assets/images/player_tank.png',
      'lastSeen': 'Now',
    },
    {
      'name': 'SharpShooter99',
      'status': 'In Match',
      'level': 28,
      'avatar': 'assets/images/enemy_tank.png',
      'lastSeen': 'Now',
    },
    {
      'name': 'BattleQueen',
      'status': 'Offline',
      'level': 45,
      'avatar': 'assets/images/player_tank.png',
      'lastSeen': '2 hours ago',
    },
    {
      'name': 'DestroyerX',
      'status': 'Online',
      'level': 19,
      'avatar': 'assets/images/enemy_tank.png',
      'lastSeen': 'Now',
    },
    {
      'name': 'TankRoller',
      'status': 'Offline',
      'level': 37,
      'avatar': 'assets/images/player_tank.png',
      'lastSeen': '1 day ago',
    },
  ];

  // Sample friend requests
  final List<Map<String, dynamic>> _friendRequests = [
    {
      'name': 'ArmorSlayer',
      'level': 22,
      'avatar': 'assets/images/enemy_tank.png',
    },
    {
      'name': 'TankHunter',
      'level': 15,
      'avatar': 'assets/images/player_tank.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FRIENDS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddFriendDialog,
            tooltip: 'Add Friend',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'FRIENDS LIST'),
            Tab(text: 'REQUESTS'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.purple.shade900.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFriendsList(),
                  _buildFriendRequestsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search friends...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.black45,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.purple.shade800),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.purple.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
          ),
        ),
        onChanged: (value) {
          // TODO: Implement search functionality
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFriendsList() {
    final filteredFriends = _friends.where((friend) {
      return friend['name'].toString().toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
    }).toList();

    return filteredFriends.isEmpty
        ? const Center(
      child: Text(
        'No friends found',
        style: TextStyle(color: Colors.white70, fontSize: 18),
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: filteredFriends.length,
      itemBuilder: (context, index) {
        final friend = filteredFriends[index];
        final isOnline = friend['status'] == 'Online' || friend['status'] == 'In Match';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isOnline ? Colors.green.shade800 : Colors.grey.shade800,
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(friend['avatar']),
                  backgroundColor: Colors.blue.shade900,
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              friend['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${friend['status']} • Level ${friend['level']}',
              style: TextStyle(
                color: isOnline ? Colors.green.shade300 : Colors.grey,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isOnline)
                  IconButton(
                    icon: const Icon(Icons.videogame_asset, color: Colors.amber),
                    onPressed: () => _inviteToGame(friend),
                    tooltip: 'Invite to Game',
                  ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.blue),
                  onPressed: () => _openChat(friend),
                  tooltip: 'Chat',
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () => _showFriendOptions(friend),
                  tooltip: 'More Options',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFriendRequestsList() {
    return _friendRequests.isEmpty
        ? const Center(
      child: Text(
        'No pending friend requests',
        style: TextStyle(color: Colors.white70, fontSize: 18),
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _friendRequests.length,
      itemBuilder: (context, index) {
        final request = _friendRequests[index];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.amber.shade800,
              width: 1,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(request['avatar']),
              backgroundColor: Colors.purple.shade900,
            ),
            title: Text(
              request['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Level ${request['level']}',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _acceptFriendRequest(request),
                  tooltip: 'Accept',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _declineFriendRequest(request),
                  tooltip: 'Decline',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Add Friend',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter username',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.black45,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple.shade800),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple.shade800),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
            ),
            child: const Text('Send Request'),
            onPressed: () {
              // TODO: Implement send friend request logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Friend request sent!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _inviteToGame(Map<String, dynamic> friend) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invited ${friend['name']} to play!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _openChat(Map<String, dynamic> friend) {
    // TODO: Implement chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat with ${friend['name']} - Coming Soon!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showFriendOptions(Map<String, dynamic> friend) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('View Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement view profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.orange),
              title: const Text('Block User', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement block functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text('Remove Friend', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _removeFriend(friend);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _acceptFriendRequest(Map<String, dynamic> request) {
    setState(() {
      _friendRequests.remove(request);
      _friends.add({
        'name': request['name'],
        'status': 'Online',
        'level': request['level'],
        'avatar': request['avatar'],
        'lastSeen': 'Now',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You are now friends with ${request['name']}!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _declineFriendRequest(Map<String, dynamic> request) {
    setState(() {
      _friendRequests.remove(request);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request from ${request['name']} declined'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _removeFriend(Map<String, dynamic> friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          'Remove ${friend['name']}?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove ${friend['name']} from your friends list?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: const Text('Remove'),
            onPressed: () {
              setState(() {
                _friends.remove(friend);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${friend['name']} removed from friends'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}