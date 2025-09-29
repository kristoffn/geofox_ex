defmodule Geofox.Types do
  @moduledoc """
  Type definitions for Geofox API structures based on the OpenAPI specification.
  """

  # Enumeration types
  @type coordinate_type :: String.t()

  @type vehicle_type ::
          :REGIONALBUS
          | :METROBUS
          | :NACHTBUS
          | :SCHNELLBUS
          | :XPRESSBUS
          | :AST
          | :SCHIFF
          | :U_BAHN
          | :S_BAHN
          | :A_BAHN
          | :R_BAHN
          | :F_BAHN
          | :EILBUS

  @type service_type ::
          :BUS
          | :TRAIN
          | :SHIP
          | :FOOTPATH
          | :BICYCLE
          | :AIRPLANE
          | :CHANGE
          | :CHANGE_SAME_PLATFORM
          | :ACTIVITY_BIKE_AND_RIDE

  @type simple_service_type ::
          :BUS
          | :TRAIN
          | :SHIP
          | :FOOTPATH
          | :BICYCLE
          | :AIRPLANE
          | :CHANGE
          | :CHANGE_SAME_PLATFORM
          | :ACTIVITY_BIKE_AND_RIDE

  @type person_type :: :ALL | :ADULT | :ELDERLY | :APPRENTICE | :PUPIL | :STUDENT | :CHILD

  @type region_type ::
          :ZONE | :GH_ZONE | :RING | :COUNTY | :GH | :NET | :ZG | :STADTVERKEHR

  @type location_type ::
          :UNKNOWN
          | :STATION
          | :ADDRESS
          | :POI
          | :COORDINATE
          | :BIKE_AND_RIDE
          | :STOP_POINT

  @type filter_type :: :NO_FILTER | :HVV_LISTED

  @type ticket_class :: :NONE | :SECOND | :FIRST | :SCHNELL

  @type discount_type :: :NONE | :ONLINE | :SOCIAL

  @type extra_fare_type :: :NO | :POSSIBLE | :REQUIRED

  @type realtime_type :: :PLANDATA | :REALTIME | :AUTO

  @type day_type :: :WEEKDAY | :WEEKEND

  @type button_type :: :BRAILLE | :ACUSTIC | :COMBI | :UNKNOWN

  @type elevator_state :: :READY | :OUTOFORDER | :UNKNOWN

  @type shop_type :: :AST

  @type ticket_type :: :OCCASIONAL_TICKET | :SEASON_TICKET

  @type modification_type :: :MAIN | :POSITION | :SEQUENCE

  @type segments_type :: :BEFORE | :AFTER | :ALL

  @type filter_planned :: :NO_FILTER | :ONLY_PLANNED | :ONLY_UNPLANNED

  @type profile_type ::
          :BICYCLE_NORMAL | :BICYCLE_RACING | :BICYCLE_QUIET_ROADS
          | :BICYCLE_MAIN_ROADS | :BICYCLE_BAD_WEATHER
          | :FOOT_NORMAL

  @type speed_type :: :NORMAL

  # Core data structures
  @type coordinate :: %{
          x: number(),
          y: number(),
          type: String.t()
        }

  @type gti_time :: %{
          date: String.t(),
          time: String.t()
        }

  @type time_period :: %{
          begin: String.t(),
          end: String.t()
        }

  @type time_range :: %{
          begin: String.t(),
          end: String.t()
        }

  @type validity_period :: %{
          day: day_type(),
          timeValidities: [time_period()]
        }

  @type service_type_info :: %{
          simpleType: simple_service_type(),
          shortInfo: String.t() | nil,
          longInfo: String.t() | nil,
          model: String.t() | nil
        }

  @type tariff_details :: %{
          innerCity: boolean() | nil,
          city: boolean() | nil,
          cityTraffic: boolean() | nil,
          gratis: boolean() | nil,
          greaterArea: boolean() | nil,
          shVillageId: integer() | nil,
          shTariffZone: integer() | nil,
          tariffZones: [integer()] | nil,
          regions: [integer()] | nil,
          counties: [String.t()] | nil,
          rings: [String.t()] | nil,
          fareStage: boolean() | nil,
          fareStageNumber: integer() | nil,
          tariffNames: [String.t()] | nil,
          uniqueValues: boolean() | nil
        }

  @type sd_name :: %{
          name: String.t() | nil,
          city: String.t() | nil,
          combinedName: String.t() | nil,
          id: String.t(),
          globalId: String.t() | nil,
          provider: String.t() | nil,
          type: location_type(),
          coordinate: coordinate() | nil,
          layer: integer() | nil,
          tariffDetails: tariff_details() | nil,
          serviceTypes: [String.t()] | nil,
          hasStationInformation: boolean() | nil,
          address: String.t() | nil
        }

  @type journey_sd_name :: %{
          name: String.t() | nil,
          city: String.t() | nil,
          combinedName: String.t() | nil,
          id: String.t(),
          globalId: String.t() | nil,
          provider: String.t() | nil,
          type: location_type(),
          coordinate: coordinate() | nil,
          layer: integer() | nil,
          tariffDetails: tariff_details() | nil,
          serviceTypes: [String.t()] | nil,
          hasStationInformation: boolean() | nil,
          address: String.t() | nil,
          arrTime: gti_time() | nil,
          depTime: gti_time() | nil,
          arrDelay: integer() | nil,
          depDelay: integer() | nil,
          extra: boolean(),
          cancelled: boolean(),
          attributes: [attribute()] | nil,
          platform: String.t() | nil,
          realtimePlatform: String.t() | nil
        }

  @type station_light :: %{
          id: String.t(),
          name: String.t()
        }

  @type service :: %{
          name: String.t(),
          direction: String.t() | nil,
          directionId: integer() | nil,
          origin: String.t() | nil,
          type: service_type_info(),
          id: String.t() | nil,
          dlid: String.t() | nil,
          carrierNameShort: String.t() | nil,
          carrierNameLong: String.t() | nil
        }

  @type attribute :: %{
          title: String.t() | nil,
          isPlanned: boolean() | nil,
          value: String.t(),
          types: [String.t()] | nil,
          id: String.t() | nil
        }

  @type vehicle :: %{
          id: String.t() | nil,
          number: String.t() | nil
        }

  @type person_info :: %{
          personType: person_type(),
          personCount: integer() | nil
        }

  @type property :: %{
          key: String.t(),
          value: String.t() | nil
        }

  @type bounding_box :: %{
          lowerLeft: coordinate(),
          upperRight: coordinate()
        }

  # Tariff and ticket structures
  @type tariff_zone :: %{
          zone: String.t(),
          ring: String.t(),
          neighbours: [String.t()]
        }

  @type tariff_county :: %{
          id: String.t(),
          label: String.t()
        }

  @type required_region_type :: %{
          type: region_type(),
          count: integer() | nil
        }

  @type tariff_kind :: %{
          id: integer() | nil,
          label: String.t(),
          requiresPersonType: boolean(),
          ticketType: ticket_type() | nil,
          levelCombinations: [integer()] | nil
        }

  @type tariff_level :: %{
          id: integer() | nil,
          label: String.t(),
          requiredRegionType: required_region_type()
        }

  @type ticket_variant :: %{
          ticketId: integer() | nil,
          kaNummer: integer() | nil,
          price: float() | nil,
          currency: String.t(),
          ticketClass: ticket_class(),
          discount: discount_type(),
          validityBegin: String.t(),
          validityEnd: String.t()
        }

  @type ticket_info_basic :: %{
          tariffKindID: integer() | nil,
          tariffKindLabel: String.t(),
          tariffLevelID: integer() | nil,
          tariffLevelLabel: String.t(),
          tariffGroupID: integer() | nil,
          tariffGroupLabel: String.t() | nil,
          regionType: region_type() | nil,
          selectableRegions: integer(),
          requiredStartStation: boolean(),
          personInfos: [person_info()] | nil,
          validityPeriods: [validity_period()] | nil,
          variants: [ticket_variant()] | nil
        }

  @type tariff_regions :: %{
          regions: [String.t()]
        }

  @type tariff_optimizer_regions :: %{
          zones: [tariff_regions()] | nil,
          rings: [tariff_regions()] | nil,
          counties: [tariff_regions()] | nil
        }

  @type tariff_optimizer_ticket :: %{
          tariffKindId: integer() | nil,
          tariffKindLabel: String.t() | nil,
          tariffLevelId: integer() | nil,
          tariffLevelLabel: String.t() | nil,
          tariffRegions: [String.t()],
          regionType: region_type(),
          count: integer() | nil,
          extraFare: boolean() | nil,
          personType: person_type(),
          centPrice: integer() | nil
        }

  # Station and line structures
  @type station_list_entry :: %{
          id: String.t(),
          name: String.t() | nil,
          city: String.t() | nil,
          combinedName: String.t() | nil,
          shortcuts: [String.t()] | nil,
          aliasses: [String.t()] | nil,
          vehicleTypes: [vehicle_type()] | nil,
          coordinate: coordinate() | nil,
          exists: boolean()
        }

  @type subline_list_entry :: %{
          sublineNumber: String.t(),
          vehicleType: vehicle_type(),
          stationSequence: [station_light()] | nil
        }

  @type line_list_entry :: %{
          id: String.t(),
          name: String.t() | nil,
          carrierNameShort: String.t() | nil,
          carrierNameLong: String.t() | nil,
          sublines: [subline_list_entry()] | nil,
          exists: boolean(),
          type: service_type_info()
        }

  # Elevator and station information
  @type elevator :: %{
          lines: [String.t()] | nil,
          label: String.t() | nil,
          cabinWidth: integer() | nil,
          cabinLength: integer() | nil,
          doorWidth: integer() | nil,
          description: String.t() | nil,
          elevatorType: String.t() | nil,
          buttonType: button_type() | nil,
          state: elevator_state() | nil,
          cause: String.t() | nil
        }

  @type partial_station :: %{
          lines: [String.t()] | nil,
          stationOutline: String.t() | nil,
          elevators: [elevator()] | nil
        }

  # Departure and journey structures
  @type departure :: %{
          line: service(),
          directionId: integer() | nil,
          timeOffset: integer() | nil,
          delay: integer() | nil,
          extra: boolean(),
          cancelled: boolean(),
          serviceId: integer() | nil,
          station: sd_name() | nil,
          stopPoint: sd_name() | nil,
          platform: String.t() | nil,
          realtimePlatform: String.t() | nil,
          vehicles: [vehicle()] | nil,
          attributes: [attribute()] | nil
        }

  @type dl_filter_entry :: %{
          serviceID: String.t() | nil,
          stationIDs: [String.t()] | nil,
          label: String.t() | nil,
          serviceName: String.t() | nil
        }

  # Path and tracking structures
  @type map_entry :: %{
          key: String.t(),
          value: String.t()
        }

  @type path :: %{
          track: [coordinate()],
          attributes: [String.t()] | nil,
          tags: [map_entry()] | nil
        }

  @type vehicle_map_path :: %{
          track: [float()] | nil,
          coordinateType: coordinate_type()
        }

  @type path_segment :: %{
          startStopPointKey: String.t(),
          endStopPointKey: String.t(),
          startStationName: String.t(),
          startStationKey: String.t(),
          startDateTime: integer(),
          endStationName: String.t(),
          endStationKey: String.t(),
          endDateTime: integer(),
          track: vehicle_map_path(),
          destination: String.t(),
          realtimeDelay: integer() | nil,
          isFirst: boolean() | nil,
          isLast: boolean() | nil
        }

  @type journey :: %{
          journeyID: String.t(),
          line: service(),
          vehicleType: vehicle_type(),
          realtime: boolean() | nil,
          segments: [path_segment()] | nil
        }

  # Announcement structures
  @type link :: %{
          label: String.t(),
          url: String.t()
        }

  @type location :: %{
          type: String.t(),
          name: String.t() | nil,
          line: service() | nil,
          begin: sd_name() | nil,
          end: sd_name() | nil,
          bothDirections: boolean()
        }

  @type announcement :: %{
          id: String.t() | nil,
          version: integer() | nil,
          summary: String.t() | nil,
          locations: [location()] | nil,
          description: String.t(),
          links: [link()] | nil,
          publication: time_range(),
          validities: [time_range()],
          lastModified: String.t(),
          planned: boolean() | nil,
          reason: String.t() | nil,
          broadcastRelevant: boolean() | nil
        }

  # Route and schedule structures
  @type individual_track :: %{
          time: integer(),
          length: integer(),
          type: service_type()
        }

  @type course_element :: %{
          fromStation: sd_name(),
          fromPlatform: String.t() | nil,
          fromRealtimePlatform: String.t() | nil,
          toStation: sd_name(),
          toPlatform: String.t() | nil,
          toRealtimePlatform: String.t() | nil,
          model: String.t() | nil,
          depTime: String.t(),
          arrTime: String.t(),
          depDelay: integer() | nil,
          arrDelay: integer() | nil,
          fromExtra: boolean(),
          fromCancelled: boolean(),
          toExtra: boolean(),
          toCancelled: boolean(),
          attributes: [attribute()] | nil,
          path: path() | nil
        }

  @type shop_info :: %{
          shopType: shop_type(),
          url: String.t()
        }

  @type schedule_element :: %{
          from: journey_sd_name(),
          to: journey_sd_name(),
          line: service(),
          paths: [path()] | nil,
          attributes: [attribute()] | nil,
          announcements: [announcement()] | nil,
          extra: boolean(),
          cancelled: boolean(),
          intermediateStops: [journey_sd_name()] | nil,
          vehicles: [vehicle()] | nil,
          serviceId: integer() | nil,
          shopInfo: [shop_info()] | nil
        }

  @type cont_search_by_service_id :: %{
          serviceId: integer(),
          lineKey: String.t(),
          plannedDepArrTime: gti_time(),
          additionalOffset: integer() | nil
        }

  @type ticket :: %{
          price: float() | nil,
          reducedPrice: float() | nil,
          currency: String.t(),
          type: String.t(),
          level: String.t(),
          tariff: String.t(),
          range: String.t() | nil,
          ticketRemarks: String.t() | nil
        }

  @type tariff_region_info :: %{
          regionType: region_type(),
          alternatives: [tariff_regions()] | nil
        }

  @type tariff_info :: %{
          tariffName: String.t(),
          tariffRegions: [tariff_region_info()] | nil,
          regionTexts: [String.t()] | nil,
          extraFareType: extra_fare_type(),
          ticketInfos: [map()] | nil,
          ticketRemarks: String.t() | nil
        }

  @type schedule :: %{
          routeId: integer() | nil,
          start: sd_name(),
          dest: sd_name(),
          time: integer() | nil,
          footpathTime: integer() | nil,
          plannedDepartureTime: String.t() | nil,
          realDepartureTime: String.t() | nil,
          plannedArrivalTime: String.t() | nil,
          realArrivalTime: String.t() | nil,
          tickets: [ticket()] | nil,
          tariffInfos: [tariff_info()] | nil,
          scheduleElements: [schedule_element()] | nil,
          contSearchBefore: cont_search_by_service_id() | nil,
          contSearchAfter: cont_search_by_service_id() | nil
        }

  @type individual_route :: %{
          start: sd_name(),
          dest: sd_name(),
          path: path() | nil,
          paths: [path()] | nil,
          length: integer() | nil,
          time: integer() | nil,
          serviceType: service_type()
        }

  @type penalty :: %{
          name: String.t(),
          value: String.t()
        }

  @type tariff_info_selector :: %{
          tariff: String.t(),
          tariffRegions: boolean(),
          kinds: [integer()] | nil,
          groups: [integer()] | nil,
          blacklist: boolean()
        }
end
