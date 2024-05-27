import 'dart:convert';
import 'package:eorderbook/models/account.dart';
import 'package:eorderbook/models/area.dart';
import 'package:eorderbook/models/company.dart';
import 'package:eorderbook/models/product.dart';
import 'package:eorderbook/models/sector.dart';
import 'package:eorderbook/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'db_helper.dart'; // Import all your model classes

class ApiService {
  static const String baseUrl = 'https://seasoftsales.com/eorderbook';


  Future<bool> syncData(String distCode) async {
    // Truncate all tables before syncing new data
    await DatabaseHelper.instance.truncateAllTables();

    // Fetch data from the API
    final List<Account> accounts = await getAccounts(distCode);
    final List<Area> areas = await getAreas(distCode);
    final List<Company> companies = await getCompanies(distCode);
    final List<Product> products = await getProducts(distCode);
    final List<Sector> sectors = await getSectors(distCode);
    final List<User> users = await getUsers(distCode);

    // Bulk insert data into local database
    await DatabaseHelper.instance.bulkInsertAccounts(accounts);
    await DatabaseHelper.instance.bulkInsertAreas(areas);
    await DatabaseHelper.instance.bulkInsertCompanies(companies);
    await DatabaseHelper.instance.bulkInsertProducts(products);
    await DatabaseHelper.instance.bulkInsertSectors(sectors);
    await DatabaseHelper.instance.bulkInsertUsers(users);

    return true;
  }

  Future<bool> checkDistCodeAvailability(String distCode) async {
    final Map<String, String> requestData = {'dist_code': distCode};
    final String requestBody = json.encode(requestData);

    final response = await http.post(
      Uri.parse('$baseUrl/check_dist_code.php'), // Replace with your API endpoint for checking dist_code
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      // Assuming the response contains a boolean value indicating the availability
      return json.decode(response.body)['available'] ?? false;
    } else {
      throw Exception('Failed to check dist_code availability');
    }
  }

  Future<bool> syncDataIfDistCodeAvailable(String distCode) async {
    // Check if dist_code is available on the server
    bool distCodeAvailable = await checkDistCodeAvailability(distCode);

    if (distCodeAvailable) {
      // Dist_code is available, proceed with syncing data
      return await syncData(distCode);
    } else {
      // Dist_code is not available, handle accordingly (throw an exception, return false, etc.)
      throw Exception('Dist_code not available on the server');
    }
  }
  Future<String> getCheckLicExpDate(String distCode) async {
    // Make API call to retrieve data for the given distCode
    String apiUrl = 'https://seasoftsales.com/eorderbook/get_distcode.php?dist_code=$distCode';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Parse the response JSON
      List<dynamic> responseData = json.decode(response.body);

      // Extract the value of 'check_lic_expdate' from the first item in the list
      if (responseData.isNotEmpty) {
        String checkLicExpDate = responseData[0]['check_lic_expdate'];
        return checkLicExpDate;
      } else {
        throw Exception('No data found for dist_code: $distCode');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  }
  Future<List<Account>> getAccounts(distCode) async {
    final Map<String, String> requestData = {'dist_code': distCode};
    final String requestBody = json.encode(requestData);

    final response = await http.post(
      Uri.parse('$baseUrl/get_accounts.php'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Account.fromJson(json)).toList();
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<Area>> getAreas(distCode) async {
    final Map<String, String> requestData = {'dist_code': distCode};
    final String requestBody = json.encode(requestData);

    final response = await http.post(
      Uri.parse('$baseUrl/get_areas.php'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Area.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load areas');
    }
  }

  Future<List<Company>> getCompanies(distCode) async {
    final Map<String, String> requestData = {'dist_code': distCode};
    final String requestBody = json.encode(requestData);

    final response = await http.post(
      Uri.parse('$baseUrl/get_companies.php'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Company.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load companies');
    }
  }
  Future<bool> validateDistCode(String distCode, String securityKey) async {
    // Replace "your_api_url" with the actual URL where your PHP script is hosted
    final apiUrl = "https://seasoftsales.com/eorderbook/dist_login.php";

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'dist_code': distCode,
        'security_key': securityKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['valid'] ?? false;
    } else {
      throw Exception('Failed to validate distributor code');
    }
  }
  // Future<List<Distributor>> getDistributors() async {
  //   final response = await http.get(Uri.parse('$baseUrl/get_distributors.php'));
  //
  //   if (response.statusCode == 200) {
  //     List<dynamic> data = json.decode(response.body);
  //     return data.map((json) => Distributor.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to load distributors');
  //   }
  // }

  Future<List<Product>> getProducts(distCode) async {
    final Map<String, String> requestData = {'dist_code': distCode};
    final String requestBody = json.encode(requestData);

    final response = await http.post( 
      Uri.parse('$baseUrl/get_products.php'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Sector>> getSectors(distCode) async {
    final Map<String, String> requestData = {'dist_code': distCode};
    final String requestBody = json.encode(requestData);

    final response = await http.post(
      Uri.parse('$baseUrl/get_sectors.php'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Sector.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sectors');
    }
  }

  Future<List<User>> getUsers(distCode) async {
    final Map<String, String> requestData = {'dist_code': distCode};
    final String requestBody = json.encode(requestData);

    final response = await http.post(
      Uri.parse('$baseUrl/get_users.php'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Future<void> postOrder(Map<String, dynamic> orderDetails, List<Map<String, dynamic>> productDetails) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/post_order.php'), // Replace with your API endpoint for posting orders
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({
  //       'orderDetails': orderDetails,
  //       'productDetails': productDetails,
  //     }),
  //   );
  //
  //   if (response.statusCode == 201) {
  //     // Successfully posted order
  //   } else {
  //     throw Exception('Failed to post order');
  //   }
  // }

  Future<bool> postAllOrders(json) async {
    final Uri postOrderUrl = Uri.parse('$baseUrl/post_orders.php');

    try {
        final response = await http.post(
          postOrderUrl,
          headers: {'Content-Type': 'application/json'},
          body: json,
        );

        if (response.statusCode == 201) {
          debugPrint('Order posted successfully: ${jsonDecode(response.body)}');
        } else {
          debugPrint('Failed to post order: ${response.statusCode} - ${response.body}');
          return false;
        }
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
    return  true;
  }
}