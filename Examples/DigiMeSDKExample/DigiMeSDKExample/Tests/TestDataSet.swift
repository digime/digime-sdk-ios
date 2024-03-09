//
//  TestDataSet.swift
//  DigiMeSDKExample
//
//  Created on 03/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeSDK
import SwiftUI

enum TestLogs {
    static let dataset = [
        LogEntry(message: "an error occured", state: .error),
        LogEntry(message: "warning message", state: .warning),
        LogEntry(message: "normal activity registered"),
        LogEntry(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
    ]
}

enum TestTimeRangeTemplates {
	static let date = Date()

	// "Today"
	static let startOfToday = Calendar.current.startOfDay(for: date)
	static let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!

	// "Yesterday"
	static let startOfYesterday = Calendar.current.date(byAdding: .day, value: -1, to: startOfToday)!
	static let endOfYesterday = Calendar.current.date(byAdding: .day, value: 1, to: startOfYesterday)!

	// "This Week"
	static let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
	static let endOfWeek = Calendar.current.date(byAdding: .day, value: 1, to: startOfWeek.addingTimeInterval(7 * 24 * 60 * 60))!
	
	// "Last Week"
	static let startOfLastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: startOfWeek)!
	static let endOfLastWeek = startOfWeek

	// "This Month"
	static let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
	static let endOfMonth = date

	// "Last Month"
	static let startOfLastMonth = Calendar.current.date(byAdding: .month, value: -1, to: startOfMonth)!
	static let endOfLastMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfLastMonth)!

	// "This Year"
	static let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: date))!
	static let endOfYear = date

	// "Last Year"
	static let startOfLastYear = Calendar.current.date(byAdding: .year, value: -1, to: startOfYear)!
	static let endOfLastYear = Calendar.current.date(byAdding: .day, value: -1, to: startOfYear)!
    static let data: [TimeRangeTemplate] = [
        TimeRangeTemplate(name: "no time limits", timeRange: nil),
        TimeRangeTemplate(name: "Today", timeRange: TimeRange.between(from: startOfToday, to: endOfToday)),
        TimeRangeTemplate(name: "Yesterday", timeRange: TimeRange.between(from: startOfYesterday, to: endOfYesterday)),
        TimeRangeTemplate(name: "This Week", timeRange: TimeRange.between(from: startOfWeek, to: endOfWeek)),
        TimeRangeTemplate(name: "Last Week", timeRange: TimeRange.between(from: startOfLastWeek, to: endOfLastWeek)),
        TimeRangeTemplate(name: "This Month", timeRange: TimeRange.between(from: startOfMonth, to: endOfMonth)),
        TimeRangeTemplate(name: "Last Month", timeRange: TimeRange.between(from: startOfLastMonth, to: endOfLastMonth)),
        TimeRangeTemplate(name: "This Year", timeRange: TimeRange.between(from: startOfYear, to: endOfYear)),
        TimeRangeTemplate(name: "Last Year", timeRange: TimeRange.between(from: startOfLastYear, to: endOfLastYear)),
        TimeRangeTemplate(name: "Custom ..."),
    ]
}

enum TestServiceObjectTypesByGroups {
    static let data: [GroupObjectType] = [
        GroupObjectType(identifier: 1, items: [
            ServiceObjectType(identifier: 1, name: "Media"),
            ServiceObjectType(identifier: 2, name: "Post"),
            ServiceObjectType(identifier: 7, name: "Comment"),
            ServiceObjectType(identifier: 10, name: "Like"),
            ServiceObjectType(identifier: 12, name: "Media Album"),
            ServiceObjectType(identifier: 15, name: "Social Network User"),
            ServiceObjectType(identifier: 19, name: "Profile"),
        ]),
        GroupObjectType(identifier: 2, items: [
            ServiceObjectType(identifier: 100, name: "Admission"),
            ServiceObjectType(identifier: 101, name: "Arrival Ambulatory"),
            ServiceObjectType(identifier: 102, name: "Arrival Primary Health"),
            ServiceObjectType(identifier: 103, name: "Prescription"),
            ServiceObjectType(identifier: 104, name: "Medication"),
            ServiceObjectType(identifier: 105, name: "Diagnosis"),
            ServiceObjectType(identifier: 106, name: "Vaccination"),
            ServiceObjectType(identifier: 107, name: "Allergy"),
            ServiceObjectType(identifier: 108, name: "Arrival Emergency"),
            ServiceObjectType(identifier: 109, name: "Prescribed Item"),
            ServiceObjectType(identifier: 111, name: "Measurement"),
            ServiceObjectType(identifier: 127, name: "Allergy Intolerance"),
            ServiceObjectType(identifier: 128, name: "Condition"),
            ServiceObjectType(identifier: 129, name: "Immunization"),
            ServiceObjectType(identifier: 130, name: "Medication Request"),
            ServiceObjectType(identifier: 131, name: "Family Member History"),
            ServiceObjectType(identifier: 132, name: "Observation"),
            ServiceObjectType(identifier: 133, name: "Procedure"),
            ServiceObjectType(identifier: 134, name: "Diagnostic Report"),
            ServiceObjectType(identifier: 135, name: "Device"),
            ServiceObjectType(identifier: 136, name: "Encounter"),
            ServiceObjectType(identifier: 137, name: "Medication Dispense"),
            ServiceObjectType(identifier: 138, name: "Medication Statement"),
        ]),
        GroupObjectType(identifier: 3, items: [
            ServiceObjectType(identifier: 19, name: "Profile"),
            ServiceObjectType(identifier: 201, name: "Transaction"),
        ]),
        GroupObjectType(identifier: 4, items: [
            ServiceObjectType(identifier: 300, name: "Activity"),
            ServiceObjectType(identifier: 301, name: "Daily Activity Summary"),
            ServiceObjectType(identifier: 302, name: "Achievemen"),
            ServiceObjectType(identifier: 303, name: "Sleep"),
        ]),
        GroupObjectType(identifier: 5, items: [
            ServiceObjectType(identifier: 403, name: "Playlist"),
            ServiceObjectType(identifier: 404, name: "Saved Album"),
            ServiceObjectType(identifier: 405, name: "Saved Track"),
            ServiceObjectType(identifier: 406, name: "Play History"),
        ]),
    ]
}

enum TestServiceTypes {
    static let social = [
        ServiceType(identifier: 1, objectTypes: [], name: "Facebook"),
        ServiceType(identifier: 2, objectTypes: [], name: "Twitter"),
        ServiceType(identifier: 6, objectTypes: [], name: "Flickr"),
        ServiceType(identifier: 283, objectTypes: [], name: "Facebook Page"),
        ServiceType(identifier: 420, objectTypes: [], name: "Instagram"),
    ]
    
    static let medical = [
        ServiceType(identifier: 20_002, objectTypes: [], name: "NL - Duoreshablehuisartsenhuisartsomdehoek Huisartspraktijk Sgravenhage (Huisartsgegevens)"),
        ServiceType(identifier: 20_001, objectTypes: [], name: "NL - Huisartsenpraktijkarchipel Huisarts Sgravenhage (Huisartsgegevens)"),
        ServiceType(identifier: 20_004, objectTypes: [], name: "NL - Huisartsenpraktijkdebiezen Huisartspraktijk Dordrecht (Huisartsgegevens)"),
        ServiceType(identifier: 20_005, objectTypes: [], name: "NL - Huisartsenpraktijkhetbaken Huisarts Denhaag (Huisartsgegevens)"),
        ServiceType(identifier: 20_003, objectTypes: [], name: "NL - Jwvandoornhuisarts Huisartspraktijk Sgravenhage (Huisartsgegevens)"),
        ServiceType(identifier: 280, objectTypes: [], name: "England GP Records"),
        ServiceType(identifier: 358, objectTypes: [], name: "US - Access Community Health Network"),
        ServiceType(identifier: 10_001, objectTypes: [], name: "US - Adult & Pediatric Ear, Nose & Throat – Kalamazoo"),
        ServiceType(identifier: 10_102, objectTypes: [], name: "US - AdventHealth"),
        ServiceType(identifier: 285, objectTypes: [], name: "US - Adventist Health West"),
        ServiceType(identifier: 328, objectTypes: [], name: "US - Akron Children's Hospital"),
        ServiceType(identifier: 359, objectTypes: [], name: "US - Alameda Health System"),
        ServiceType(identifier: 131, objectTypes: [], name: "US - Allegheny Health Network"),
        ServiceType(identifier: 132, objectTypes: [], name: "US - Allina Health System"),
        ServiceType(identifier: 10_144, objectTypes: [], name: "US - Altais"),
        ServiceType(identifier: 360, objectTypes: [], name: "US - AltaMed"),
        ServiceType(identifier: 18, objectTypes: [], name: "US - Altru Health System"),
        ServiceType(identifier: 361, objectTypes: [], name: "US - AnMed Health"),
        ServiceType(identifier: 10_003, objectTypes: [], name: "US - Arizona Community Physicians"),
        ServiceType(identifier: 362, objectTypes: [], name: "US - Arkansas Children's"),
        ServiceType(identifier: 10_004, objectTypes: [], name: "US - Arrowhead Regional Medical Center"),
        ServiceType(identifier: 363, objectTypes: [], name: "US - Asante Health Systems"),
        ServiceType(identifier: 10_132, objectTypes: [], name: "US - Ascension Illinois"),
        ServiceType(identifier: 10_131, objectTypes: [], name: "US - Ascension Providence"),
        ServiceType(identifier: 10_133, objectTypes: [], name: "US - Ascension Wisconsin"),
        ServiceType(identifier: 10_127, objectTypes: [], name: "US - Aspen Valley Hospital"),
        ServiceType(identifier: 133, objectTypes: [], name: "US - Atlantic Health"),
        ServiceType(identifier: 10_005, objectTypes: [], name: "US - Atrium Health"),
        ServiceType(identifier: 10_006, objectTypes: [], name: "US - Atrium Health Wake Forest Baptist"),
        ServiceType(identifier: 21, objectTypes: [], name: "US - Atrius Health"),
        ServiceType(identifier: 22, objectTypes: [], name: "US - Aurora Health Care - myAurora"),
        ServiceType(identifier: 134, objectTypes: [], name: "US - Austin Regional Clinic"),
        ServiceType(identifier: 329, objectTypes: [], name: "US - Ballad Health"),
        ServiceType(identifier: 10_105, objectTypes: [], name: "US - Baptist Health - Northeast Florida"),
        ServiceType(identifier: 186, objectTypes: [], name: "US - Baptist Memorial Health Care"),
        ServiceType(identifier: 187, objectTypes: [], name: "US - Bassett Healthcare"),
        ServiceType(identifier: 23, objectTypes: [], name: "US - BayCare Clinic - myBayCare"),
        ServiceType(identifier: 287, objectTypes: [], name: "US - Bayhealth Medical Center"),
        ServiceType(identifier: 24, objectTypes: [], name: "US - Baylor College of Medicine"),
        ServiceType(identifier: 10_120, objectTypes: [], name: "US - Baylor Scott & White"),
        ServiceType(identifier: 26, objectTypes: [], name: "US - BJC & Washington University"),
        ServiceType(identifier: 188, objectTypes: [], name: "US - Boston Medical Center"),
        ServiceType(identifier: 10_139, objectTypes: [], name: "US - Bozeman Health - PRD"),
        ServiceType(identifier: 27, objectTypes: [], name: "US - Bronson Healthcare Group"),
        ServiceType(identifier: 290, objectTypes: [], name: "US - Brookwood Baptist Health"),
        ServiceType(identifier: 189, objectTypes: [], name: "US - Bryan Health"),
        ServiceType(identifier: 190, objectTypes: [], name: "US - Cambridge Health Alliance"),
        ServiceType(identifier: 10_009, objectTypes: [], name: "US - Cape Cod Healthcare"),
        ServiceType(identifier: 365, objectTypes: [], name: "US - Cape Fear Valley Health"),
        ServiceType(identifier: 366, objectTypes: [], name: "US - Care New England"),
        ServiceType(identifier: 28, objectTypes: [], name: "US - Carle Foundation Hospital & Physician Group"),
        ServiceType(identifier: 10_012, objectTypes: [], name: "US - Catholic Health System (Buffalo)"),
        ServiceType(identifier: 29, objectTypes: [], name: "US - Cedars-Sinai Health System"),
        ServiceType(identifier: 30, objectTypes: [], name: "US - CentraCare Health and Affiliates"),
        ServiceType(identifier: 121, objectTypes: [], name: "US - Centura Health"),
        ServiceType(identifier: 115, objectTypes: [], name: "US - Charlotte Eye Ear Nose & Throat Associates"),
        ServiceType(identifier: 368, objectTypes: [], name: "US - CHI St. Vincent"),
        ServiceType(identifier: 31, objectTypes: [], name: "US - Children's Health System of Texas"),
        ServiceType(identifier: 369, objectTypes: [], name: "US - Children's Hospital and Medical Center, Omaha Nebraska"),
        ServiceType(identifier: 330, objectTypes: [], name: "US - Children's Hospital Colorado"),
        ServiceType(identifier: 370, objectTypes: [], name: "US - Children's Hospital of Philadelphia"),
        ServiceType(identifier: 10_141, objectTypes: [], name: "US - Children's of Alabama"),
        ServiceType(identifier: 10_013, objectTypes: [], name: "US - Children's Wisconsin"),
        ServiceType(identifier: 10_114, objectTypes: [], name: "US - Childrens's Healthcare of Atlanta"),
        ServiceType(identifier: 291, objectTypes: [], name: "US - CHRISTUS Health"),
        ServiceType(identifier: 371, objectTypes: [], name: "US - Cigna Medical Group"),
        ServiceType(identifier: 10_014, objectTypes: [], name: "US - Cincinnati Children's Hospital Medical Center"),
        ServiceType(identifier: 138, objectTypes: [], name: "US - City of Hope"),
        ServiceType(identifier: 139, objectTypes: [], name: "US - Cleveland Clinic"),
        ServiceType(identifier: 10_015, objectTypes: [], name: "US - Columbia Physicians"),
        ServiceType(identifier: 292, objectTypes: [], name: "US - Columbus Regional Health"),
        ServiceType(identifier: 33, objectTypes: [], name: "US - Community Healthcare System"),
        ServiceType(identifier: 195, objectTypes: [], name: "US - Community Medical Centers"),
        ServiceType(identifier: 10_138, objectTypes: [], name: "US - CommUnityCare Health Centers"),
        ServiceType(identifier: 372, objectTypes: [], name: "US - Conemaugh Health System"),
        ServiceType(identifier: 162, objectTypes: [], name: "US - Confluence Health"),
        ServiceType(identifier: 232, objectTypes: [], name: "US - Connecticut Children's Medical Center"),
        ServiceType(identifier: 233, objectTypes: [], name: "US - Contra Costa"),
        ServiceType(identifier: 293, objectTypes: [], name: "US - Cooper University Health Care"),
        ServiceType(identifier: 34, objectTypes: [], name: "US - Covenant HealthCare"),
        ServiceType(identifier: 10_134, objectTypes: [], name: "US - CVS Health & Minute Clinic"),
        ServiceType(identifier: 234, objectTypes: [], name: "US - Dartmouth-Hitchcock"),
        ServiceType(identifier: 294, objectTypes: [], name: "US - DaVita Physician Solutions"),
        ServiceType(identifier: 10_019, objectTypes: [], name: "US - Dayton Children's Hospital"),
        ServiceType(identifier: 10_106, objectTypes: [], name: "US - Drexel Medicine"),
        ServiceType(identifier: 10_020, objectTypes: [], name: "US - Driscoll Children's Hospital"),
        ServiceType(identifier: 10_021, objectTypes: [], name: "US - Duke Health"),
        ServiceType(identifier: 10_022, objectTypes: [], name: "US - Duly Health and Care"),
        ServiceType(identifier: 35, objectTypes: [], name: "US - Eisenhower Medical Center"),
        ServiceType(identifier: 36, objectTypes: [], name: "US - El Camino Hospital"),
        ServiceType(identifier: 10_024, objectTypes: [], name: "US - El Rio Health"),
        ServiceType(identifier: 374, objectTypes: [], name: "US - Englewood Hospital and Medical Center"),
        ServiceType(identifier: 375, objectTypes: [], name: "US - Enloe Medical Center"),
        ServiceType(identifier: 376, objectTypes: [], name: "US - EPIC Management (Beaver Medical Group)"),
        ServiceType(identifier: 295, objectTypes: [], name: "US - Erlanger Health System"),
        ServiceType(identifier: 240, objectTypes: [], name: "US - Essentia Health"),
        ServiceType(identifier: 10_142, objectTypes: [], name: "US - EvergreenHealth"),
        ServiceType(identifier: 10_025, objectTypes: [], name: "US - Evernorth"),
        ServiceType(identifier: 198, objectTypes: [], name: "US - Fairview Health Services"),
        ServiceType(identifier: 163, objectTypes: [], name: "US - Family Health Center (Michigan)"),
        ServiceType(identifier: 10_026, objectTypes: [], name: "US - FastMed"),
        ServiceType(identifier: 164, objectTypes: [], name: "US - FirstHealth of the Carolinas"),
        ServiceType(identifier: 199, objectTypes: [], name: "US - Franciscan Missionaries of Our Lady Health System"),
        ServiceType(identifier: 142, objectTypes: [], name: "US - Fresenius Medical Care North America"),
        ServiceType(identifier: 200, objectTypes: [], name: "US - Froedtert Health"),
        ServiceType(identifier: 10_028, objectTypes: [], name: "US - Garnet Health"),
        ServiceType(identifier: 38, objectTypes: [], name: "US - Geisinger"),
        ServiceType(identifier: 40, objectTypes: [], name: "US - Genesis Healthcare System"),
        ServiceType(identifier: 10_029, objectTypes: [], name: "US - George Washington University Medical Faculty Associates"),
        ServiceType(identifier: 201, objectTypes: [], name: "US - Grady Health System"),
        ServiceType(identifier: 297, objectTypes: [], name: "US - Greater Baltimore Medical Center"),
        ServiceType(identifier: 41, objectTypes: [], name: "US - Gundersen Health System"),
        ServiceType(identifier: 42, objectTypes: [], name: "US - Hackensack Meridian Health"),
        ServiceType(identifier: 298, objectTypes: [], name: "US - Harris Health System"),
        ServiceType(identifier: 165, objectTypes: [], name: "US - Hartford HealthCare"),
        ServiceType(identifier: 43, objectTypes: [], name: "US - Hattiesburg Clinic and Forrest General Hospital"),
        ServiceType(identifier: 10_115, objectTypes: [], name: "US - Hawaii Pacific Health - PRD"),
        ServiceType(identifier: 377, objectTypes: [], name: "US - HealthPartners"),
        ServiceType(identifier: 10_031, objectTypes: [], name: "US - Hendricks Regional Health"),
        ServiceType(identifier: 10_032, objectTypes: [], name: "US - Hennepin Healthcare"),
        ServiceType(identifier: 10_033, objectTypes: [], name: "US - Henry Ford Health System"),
        ServiceType(identifier: 300, objectTypes: [], name: "US - Hill Physicians"),
        ServiceType(identifier: 10_034, objectTypes: [], name: "US - Hoag Memorial Hospital Presbyterian"),
        ServiceType(identifier: 45, objectTypes: [], name: "US - HonorHealth"),
        ServiceType(identifier: 236, objectTypes: [], name: "US - Hospital Sisters Health System (HSHS)"),
        ServiceType(identifier: 10_035, objectTypes: [], name: "US - Illinois Bone & Joint Institute"),
        ServiceType(identifier: 378, objectTypes: [], name: "US - Infirmary Health"),
        ServiceType(identifier: 47, objectTypes: [], name: "US - Inova and Valley Health"),
        ServiceType(identifier: 301, objectTypes: [], name: "US - Institute for Family Health"),
        ServiceType(identifier: 10_128, objectTypes: [], name: "US - Intermountain Healthcare"),
        ServiceType(identifier: 379, objectTypes: [], name: "US - Jefferson Health"),
        ServiceType(identifier: 144, objectTypes: [], name: "US - John Muir Health"),
        ServiceType(identifier: 48, objectTypes: [], name: "US - Johns Hopkins Medicine"),
        ServiceType(identifier: 380, objectTypes: [], name: "US - Kaiser Permanente - California - Northern"),
        ServiceType(identifier: 381, objectTypes: [], name: "US - Kaiser Permanente - California - Southern"),
        ServiceType(identifier: 382, objectTypes: [], name: "US - Kaiser Permanente - Colorado"),
        ServiceType(identifier: 10_036, objectTypes: [], name: "US - Kaiser Permanente - Maryland/Virginia/Washington D.C."),
        ServiceType(identifier: 385, objectTypes: [], name: "US - Kaiser Permanente - Washington"),
        ServiceType(identifier: 386, objectTypes: [], name: "US - Kaiser Permanente Hawaii / Maui Health System"),
        ServiceType(identifier: 383, objectTypes: [], name: "US - Kaiser Permanente – Georgia"),
        ServiceType(identifier: 384, objectTypes: [], name: "US - Kaiser Permanente – Oregon – SW Washington"),
        ServiceType(identifier: 10_037, objectTypes: [], name: "US - Kalamazoo College Student Health Center"),
        ServiceType(identifier: 10_038, objectTypes: [], name: "US - Kalamazoo Foot Surgery"),
        ServiceType(identifier: 10_039, objectTypes: [], name: "US - Kelsey-Seybold Clinic"),
        ServiceType(identifier: 10_040, objectTypes: [], name: "US - Kennedy Krieger Institute"),
        ServiceType(identifier: 205, objectTypes: [], name: "US - King's Daughters Medical Center"),
        ServiceType(identifier: 10_099, objectTypes: [], name: "US - Kootenai Health"),
        ServiceType(identifier: 302, objectTypes: [], name: "US - Lacy C Kessler, MD, PA"),
        ServiceType(identifier: 51, objectTypes: [], name: "US - Lakeland Health"),
        ServiceType(identifier: 52, objectTypes: [], name: "US - Lancaster General Health"),
        ServiceType(identifier: 303, objectTypes: [], name: "US - LCMC Health"),
        ServiceType(identifier: 336, objectTypes: [], name: "US - Lee Health"),
        ServiceType(identifier: 168, objectTypes: [], name: "US - Lehigh Valley Health Network"),
        ServiceType(identifier: 10_094, objectTypes: [], name: "US - Leon Medical Centers"),
        ServiceType(identifier: 169, objectTypes: [], name: "US - Lexington Medical Center"),
        ServiceType(identifier: 10_041, objectTypes: [], name: "US - Licking Memorial Health Systems"),
        ServiceType(identifier: 304, objectTypes: [], name: "US - Lifespan"),
        ServiceType(identifier: 387, objectTypes: [], name: "US - Loma Linda University Health and CareConnect Partners"),
        ServiceType(identifier: 122, objectTypes: [], name: "US - Loyola Medicine"),
        ServiceType(identifier: 10_042, objectTypes: [], name: "US - Luminis Health"),
        ServiceType(identifier: 237, objectTypes: [], name: "US - Main Line Health"),
        ServiceType(identifier: 54, objectTypes: [], name: "US - MaineHealth"),
        ServiceType(identifier: 170, objectTypes: [], name: "US - Mary Greeley Medical Center (Iowa)"),
        ServiceType(identifier: 206, objectTypes: [], name: "US - Mary Washington Healthcare"),
        ServiceType(identifier: 10_044, objectTypes: [], name: "US - Mass General Brigham"),
        ServiceType(identifier: 146, objectTypes: [], name: "US - Mayo Clinic"),
        ServiceType(identifier: 171, objectTypes: [], name: "US - McFarland Clinic (Iowa)"),
        ServiceType(identifier: 10_135, objectTypes: [], name: "US - McLeod Health"),
        ServiceType(identifier: 207, objectTypes: [], name: "US - Medical University of South Carolina"),
        ServiceType(identifier: 56, objectTypes: [], name: "US - MediSys Health Network"),
        ServiceType(identifier: 251, objectTypes: [], name: "US - Memorial Healthcare System"),
        ServiceType(identifier: 10_140, objectTypes: [], name: "US - Mercy Health (Arkansas, Louisiana, Mississippi and Texas)"),
        ServiceType(identifier: 305, objectTypes: [], name: "US - Mercy Health Services (MD)"),
        ServiceType(identifier: 110, objectTypes: [], name: "US - Mercy Medical Center"),
        ServiceType(identifier: 306, objectTypes: [], name: "US - Meritus"),
        ServiceType(identifier: 307, objectTypes: [], name: "US - Methodist Health System"),
        ServiceType(identifier: 10_116, objectTypes: [], name: "US - Methodist Hospitals - PRD"),
        ServiceType(identifier: 172, objectTypes: [], name: "US - Michigan Medicine"),
        ServiceType(identifier: 10_046, objectTypes: [], name: "US - Middlesex Hospital"),
        ServiceType(identifier: 308, objectTypes: [], name: "US - MidMichigan Health"),
        ServiceType(identifier: 390, objectTypes: [], name: "US - Mohawk Valley Health System"),
        ServiceType(identifier: 10_047, objectTypes: [], name: "US - Molina Healthcare"),
        ServiceType(identifier: 173, objectTypes: [], name: "US - Montage Health"),
        ServiceType(identifier: 208, objectTypes: [], name: "US - Montefiore Medical Center"),
        ServiceType(identifier: 10_048, objectTypes: [], name: "US - Monument Health"),
        ServiceType(identifier: 10_136, objectTypes: [], name: "US - Mosaic Life Care"),
        ServiceType(identifier: 209, objectTypes: [], name: "US - Mount Auburn Hospital"),
        ServiceType(identifier: 148, objectTypes: [], name: "US - Mount Sinai Health System"),
        ServiceType(identifier: 391, objectTypes: [], name: "US - Mount Sinai Medical Center"),
        ServiceType(identifier: 392, objectTypes: [], name: "US - MultiCare Health System"),
        ServiceType(identifier: 10_095, objectTypes: [], name: "US - Muscogee - Creek Nation Department of Health"),
        ServiceType(identifier: 10_107, objectTypes: [], name: "US - MY DR NOW"),
        ServiceType(identifier: 10_108, objectTypes: [], name: "US - Nationwide Children's Hospital"),
        ServiceType(identifier: 10_103, objectTypes: [], name: "US - NCH Healthcare System"),
        ServiceType(identifier: 60, objectTypes: [], name: "US - Nebraska Medicine"),
        ServiceType(identifier: 393, objectTypes: [], name: "US - Nemours"),
        ServiceType(identifier: 10_049, objectTypes: [], name: "US - Nephrology Center - Southwest Michigan"),
        ServiceType(identifier: 174, objectTypes: [], name: "US - New Hanover Regional Medical Center"),
        ServiceType(identifier: 10_050, objectTypes: [], name: "US - New Jersey Urology"),
        ServiceType(identifier: 10_051, objectTypes: [], name: "US - New York-Presbyterian"),
        ServiceType(identifier: 210, objectTypes: [], name: "US - North Memorial Health"),
        ServiceType(identifier: 394, objectTypes: [], name: "US - North Mississippi Health Services"),
        ServiceType(identifier: 61, objectTypes: [], name: "US - North Oaks"),
        ServiceType(identifier: 62, objectTypes: [], name: "US - NorthShore University Health System"),
        ServiceType(identifier: 211, objectTypes: [], name: "US - Northwestern Medicine"),
        ServiceType(identifier: 63, objectTypes: [], name: "US - Norton Healthcare"),
        ServiceType(identifier: 64, objectTypes: [], name: "US - Novant Health"),
        ServiceType(identifier: 10_052, objectTypes: [], name: "US - NOVO Health"),
        ServiceType(identifier: 149, objectTypes: [], name: "US - NYC Health + Hospitals"),
        ServiceType(identifier: 212, objectTypes: [], name: "US - NYU Langone Medical Center"),
        ServiceType(identifier: 309, objectTypes: [], name: "US - OB/GYN Associates of Waco - Dr. Rister, Dr. Koeritz"),
        ServiceType(identifier: 65, objectTypes: [], name: "US - OCHIN"),
        ServiceType(identifier: 66, objectTypes: [], name: "US - Ochsner Health System"),
        ServiceType(identifier: 244, objectTypes: [], name: "US - OhioHealth"),
        ServiceType(identifier: 245, objectTypes: [], name: "US - Olmsted Medical Center"),
        ServiceType(identifier: 10_053, objectTypes: [], name: "US - One Brooklyn Health System"),
        ServiceType(identifier: 10_097, objectTypes: [], name: "US - OptumCare East"),
        ServiceType(identifier: 10_100, objectTypes: [], name: "US - OptumCare West"),
        ServiceType(identifier: 213, objectTypes: [], name: "US - Oregon Health & Science University"),
        ServiceType(identifier: 10_055, objectTypes: [], name: "US - Orlando Health"),
        ServiceType(identifier: 10_056, objectTypes: [], name: "US - OrthoCarolina"),
        ServiceType(identifier: 67, objectTypes: [], name: "US - OrthoVirginia"),
        ServiceType(identifier: 395, objectTypes: [], name: "US - OSF HealthCare"),
        ServiceType(identifier: 10_057, objectTypes: [], name: "US - Pacific Dental Services"),
        ServiceType(identifier: 175, objectTypes: [], name: "US - Palos Health"),
        ServiceType(identifier: 310, objectTypes: [], name: "US - Parkland"),
        ServiceType(identifier: 69, objectTypes: [], name: "US - Parkview Health"),
        ServiceType(identifier: 215, objectTypes: [], name: "US - PeaceHealth"),
        ServiceType(identifier: 399, objectTypes: [], name: "US - Pediatric Physicians Organization at Children's"),
        ServiceType(identifier: 246, objectTypes: [], name: "US - Penn Medicine"),
        ServiceType(identifier: 10_058, objectTypes: [], name: "US - Phelps Health"),
        ServiceType(identifier: 238, objectTypes: [], name: "US - Piedmont Healthcare"),
        ServiceType(identifier: 10_126, objectTypes: [], name: "US - Pikeville Medical Center"),
        ServiceType(identifier: 10_059, objectTypes: [], name: "US - Pine Rest Christian Mental Health Services"),
        ServiceType(identifier: 10_060, objectTypes: [], name: "US - Planned Parenthood"),
        ServiceType(identifier: 70, objectTypes: [], name: "US - Premier Health"),
        ServiceType(identifier: 400, objectTypes: [], name: "US - Presbyterian Healthcare Services"),
        ServiceType(identifier: 10_061, objectTypes: [], name: "US - Prisma Health"),
        ServiceType(identifier: 401, objectTypes: [], name: "US - ProHealth Care"),
        ServiceType(identifier: 71, objectTypes: [], name: "US - Providence Health & Services - Alaska"),
        ServiceType(identifier: 72, objectTypes: [], name: "US - Providence Health & Services - Oregon/California"),
        ServiceType(identifier: 73, objectTypes: [], name: "US - Providence Health & Services - Washington/Montana"),
        ServiceType(identifier: 10_062, objectTypes: [], name: "US - QuadMed"),
        ServiceType(identifier: 402, objectTypes: [], name: "US - Rady Children's"),
        ServiceType(identifier: 10_063, objectTypes: [], name: "US - Reid Health"),
        ServiceType(identifier: 10_064, objectTypes: [], name: "US - Reliant Medical Group"),
        ServiceType(identifier: 239, objectTypes: [], name: "US - Renown, Barton, CVMC"),
        ServiceType(identifier: 10_065, objectTypes: [], name: "US - Riverside Health System (Newport News, VA)"),
        ServiceType(identifier: 404, objectTypes: [], name: "US - Riverview Health"),
        ServiceType(identifier: 112, objectTypes: [], name: "US - Rochester Regional Health"),
        ServiceType(identifier: 76, objectTypes: [], name: "US - Rush University Medical Center"),
        ServiceType(identifier: 10_066, objectTypes: [], name: "US - RWJBarnabas Health"),
        ServiceType(identifier: 313, objectTypes: [], name: "US - Saint Francis Health System"),
        ServiceType(identifier: 10_123, objectTypes: [], name: "US - Saint Francis Healthcare System (Manual)"),
        ServiceType(identifier: 116, objectTypes: [], name: "US - Saint Luke's Health System"),
        ServiceType(identifier: 77, objectTypes: [], name: "US - Salem Health"),
        ServiceType(identifier: 10_067, objectTypes: [], name: "US - Salinas Valley Memorial Healthcare Systems"),
        ServiceType(identifier: 405, objectTypes: [], name: "US - San Francisco Department of Public Health"),
        ServiceType(identifier: 78, objectTypes: [], name: "US - Sanford Health"),
        ServiceType(identifier: 79, objectTypes: [], name: "US - Sansum Clinic"),
        ServiceType(identifier: 10_068, objectTypes: [], name: "US - Santa Clara Valley Medical Center Hospitals and Clinics"),
        ServiceType(identifier: 314, objectTypes: [], name: "US - Scotland Health Care System"),
        ServiceType(identifier: 247, objectTypes: [], name: "US - Scripps Health"),
        ServiceType(identifier: 10_069, objectTypes: [], name: "US - Seattle Children's Hospital"),
        ServiceType(identifier: 10_070, objectTypes: [], name: "US - Select Medical"),
        ServiceType(identifier: 10_071, objectTypes: [], name: "US - Self Regional Healthcare"),
        ServiceType(identifier: 315, objectTypes: [], name: "US - Sentara Healthcare"),
        ServiceType(identifier: 218, objectTypes: [], name: "US - Shannon Health"),
        ServiceType(identifier: 10_130, objectTypes: [], name: "US - Shriners Children’s"),
        ServiceType(identifier: 317, objectTypes: [], name: "US - Skagit Regional Health"),
        ServiceType(identifier: 10_072, objectTypes: [], name: "US - SolutionHealth"),
        ServiceType(identifier: 318, objectTypes: [], name: "US - South Georgia Medical Center"),
        ServiceType(identifier: 10_073, objectTypes: [], name: "US - South Shore Health System"),
        ServiceType(identifier: 117, objectTypes: [], name: "US - Southcoast Health"),
        ServiceType(identifier: 10_074, objectTypes: [], name: "US - Southeast Health"),
        ServiceType(identifier: 406, objectTypes: [], name: "US - Southern Illinois Healthcare"),
        ServiceType(identifier: 320, objectTypes: [], name: "US - Sparrow Health System"),
        ServiceType(identifier: 10_121, objectTypes: [], name: "US - Spartanburg Regional Health Systems"),
        ServiceType(identifier: 82, objectTypes: [], name: "US - Spectrum Health"),
        ServiceType(identifier: 10_101, objectTypes: [], name: "US - Spectrum Health Lakeland"),
        ServiceType(identifier: 248, objectTypes: [], name: "US - St. Charles Health System"),
        ServiceType(identifier: 85, objectTypes: [], name: "US - St. Elizabeth Healthcare"),
        ServiceType(identifier: 407, objectTypes: [], name: "US - St. Joseph Hospital Health Center"),
        ServiceType(identifier: 10_125, objectTypes: [], name: "US - St. Jude Children's Research Hospital"),
        ServiceType(identifier: 321, objectTypes: [], name: "US - St. Luke's Hospital (North Carolina)"),
        ServiceType(identifier: 220, objectTypes: [], name: "US - St. Luke's University Health Network"),
        ServiceType(identifier: 151, objectTypes: [], name: "US - St. Luke’s Health System (Idaho & Eastern Oregon)"),
        ServiceType(identifier: 221, objectTypes: [], name: "US - Stanford Children's Health"),
        ServiceType(identifier: 87, objectTypes: [], name: "US - Stormont Vail Health"),
        ServiceType(identifier: 10_143, objectTypes: [], name: "US - Summa Health"),
        ServiceType(identifier: 88, objectTypes: [], name: "US - SUNY Upstate Medical University"),
        ServiceType(identifier: 126, objectTypes: [], name: "US - Sutter Health"),
        ServiceType(identifier: 409, objectTypes: [], name: "US - Tahoe Forest Health System"),
        ServiceType(identifier: 10_076, objectTypes: [], name: "US - Tampa General Hospital"),
        ServiceType(identifier: 410, objectTypes: [], name: "US - Tanner Health System"),
        ServiceType(identifier: 90, objectTypes: [], name: "US - TempleHealth"),
        ServiceType(identifier: 10_117, objectTypes: [], name: "US - Texas Children's"),
        ServiceType(identifier: 127, objectTypes: [], name: "US - Texas Health Resources"),
        ServiceType(identifier: 222, objectTypes: [], name: "US - The Brooklyn Hospital Center"),
        ServiceType(identifier: 177, objectTypes: [], name: "US - The Christ Hospital"),
        ServiceType(identifier: 223, objectTypes: [], name: "US - The Everett Clinic"),
        ServiceType(identifier: 224, objectTypes: [], name: "US - The Guthrie Clinic"),
        ServiceType(identifier: 152, objectTypes: [], name: "US - The Ohio State University Wexner Medical Center"),
        ServiceType(identifier: 92, objectTypes: [], name: "US - The Portland Clinic"),
        ServiceType(identifier: 10_077, objectTypes: [], name: "US - The University of Texas Health Science Center at Houston"),
        ServiceType(identifier: 411, objectTypes: [], name: "US - The University of Texas MD Anderson Cancer Center"),
        ServiceType(identifier: 10_110, objectTypes: [], name: "US - The University of Vermont Health Network"),
        ServiceType(identifier: 225, objectTypes: [], name: "US - The Vancouver Clinic"),
        ServiceType(identifier: 10_078, objectTypes: [], name: "US - TidalHealth"),
        ServiceType(identifier: 94, objectTypes: [], name: "US - Tower Health"),
        ServiceType(identifier: 178, objectTypes: [], name: "US - TriHealth"),
        ServiceType(identifier: 412, objectTypes: [], name: "US - Trinity Health"),
        ServiceType(identifier: 253, objectTypes: [], name: "US - Trinity Health of New England"),
        ServiceType(identifier: 322, objectTypes: [], name: "US - Trinity Health of New England Medical Group Springfield"),
        ServiceType(identifier: 10_098, objectTypes: [], name: "US - Tufts Medicine"),
        ServiceType(identifier: 10_112, objectTypes: [], name: "US - UC Davis"),
        ServiceType(identifier: 10_113, objectTypes: [], name: "US - UC Davis - MMC"),
        ServiceType(identifier: 154, objectTypes: [], name: "US - UChicago Medicine"),
        ServiceType(identifier: 95, objectTypes: [], name: "US - UCLA Medical Center"),
        ServiceType(identifier: 323, objectTypes: [], name: "US - UConn Health"),
        ServiceType(identifier: 10_081, objectTypes: [], name: "US - UCSF Benioff Children's Hospital"),
        ServiceType(identifier: 128, objectTypes: [], name: "US - UCSF Health"),
        ServiceType(identifier: 96, objectTypes: [], name: "US - UF Health"),
        ServiceType(identifier: 10_082, objectTypes: [], name: "US - UHS San Antonio"),
        ServiceType(identifier: 10_083, objectTypes: [], name: "US - UI Health"),
        ServiceType(identifier: 249, objectTypes: [], name: "US - UMass Memorial Health Care"),
        ServiceType(identifier: 414, objectTypes: [], name: "US - UMC Southern Nevada"),
        ServiceType(identifier: 97, objectTypes: [], name: "US - UNC Health Care"),
        ServiceType(identifier: 10_084, objectTypes: [], name: "US - United Health Services New York (NYUHS)"),
        ServiceType(identifier: 415, objectTypes: [], name: "US - United Regional Health Care System"),
        ServiceType(identifier: 324, objectTypes: [], name: "US - University Hospital (New Jersey)"),
        ServiceType(identifier: 10_137, objectTypes: [], name: "US - University Hospitals Cleveland"),
        ServiceType(identifier: 10_085, objectTypes: [], name: "US - University of California Irvine"),
        ServiceType(identifier: 114, objectTypes: [], name: "US - University of California San Diego"),
        ServiceType(identifier: 179, objectTypes: [], name: "US - University of Colorado Health"),
        ServiceType(identifier: 180, objectTypes: [], name: "US - University of Iowa Health Care"),
        ServiceType(identifier: 10_086, objectTypes: [], name: "US - University of Louisville Physicians"),
        ServiceType(identifier: 156, objectTypes: [], name: "US - University of Miami (UHealth)"),
        ServiceType(identifier: 157, objectTypes: [], name: "US - University of Mississippi Medical Center"),
        ServiceType(identifier: 416, objectTypes: [], name: "US - University of Pittsburgh Medical Center (UPMC)"),
        ServiceType(identifier: 10_118, objectTypes: [], name: "US - University of Rochester Medical Center - PRD"),
        ServiceType(identifier: 325, objectTypes: [], name: "US - University of Texas Medical Branch"),
        ServiceType(identifier: 10_124, objectTypes: [], name: "US - University of Toledo"),
        ServiceType(identifier: 227, objectTypes: [], name: "US - University of Utah Healthcare"),
        ServiceType(identifier: 10_122, objectTypes: [], name: "US - UPMC Central PA"),
        ServiceType(identifier: 228, objectTypes: [], name: "US - UT Health San Antonio"),
        ServiceType(identifier: 182, objectTypes: [], name: "US - UVA Health System"),
        ServiceType(identifier: 100, objectTypes: [], name: "US - UW Health And Affiliates - Wisconsin"),
        ServiceType(identifier: 229, objectTypes: [], name: "US - UW Medicine (Washington)"),
        ServiceType(identifier: 10_088, objectTypes: [], name: "US - Valley Children's Healthcare"),
        ServiceType(identifier: 10_129, objectTypes: [], name: "US - Valley Health Systems - PRD"),
        ServiceType(identifier: 101, objectTypes: [], name: "US - Valley Medical Center"),
        ServiceType(identifier: 230, objectTypes: [], name: "US - Vanderbilt"),
        ServiceType(identifier: 10_090, objectTypes: [], name: "US - VCU Health"),
        ServiceType(identifier: 327, objectTypes: [], name: "US - Virginia Hospital Center"),
        ServiceType(identifier: 231, objectTypes: [], name: "US - Virtua Health"),
        ServiceType(identifier: 10_104, objectTypes: [], name: "US - Waco Family Medicine (Heart of Texas Community Health Center)"),
        ServiceType(identifier: 158, objectTypes: [], name: "US - WakeMed Health and Hospitals"),
        ServiceType(identifier: 10_111, objectTypes: [], name: "US - Walmart"),
        ServiceType(identifier: 418, objectTypes: [], name: "US - Washington Hospital Healthcare System"),
        ServiceType(identifier: 10_091, objectTypes: [], name: "US - Watson Clinic"),
        ServiceType(identifier: 103, objectTypes: [], name: "US - Weill Cornell Medicine"),
        ServiceType(identifier: 250, objectTypes: [], name: "US - WellStar"),
        ServiceType(identifier: 10_092, objectTypes: [], name: "US - West Tennessee Healthcare"),
        ServiceType(identifier: 184, objectTypes: [], name: "US - Western Michigan University School of Medicine"),
        ServiceType(identifier: 106, objectTypes: [], name: "US - Yakima Valley Farm Workers Clinic"),
        ServiceType(identifier: 107, objectTypes: [], name: "US - Yuma Regional Medical Center"),
    ]
    
    static let finance = [
        ServiceType(identifier: 422, objectTypes: [], name: "UK Banks"),
        ServiceType(identifier: 423, objectTypes: [], name: "EU Banks"),
        ServiceType(identifier: 428, objectTypes: [], name: "Australian Banks"),
        ServiceType(identifier: 429, objectTypes: [], name: "New Zealand Banks"),
    ]
    
    static let fitness = [
        ServiceType(identifier: 15, objectTypes: [], name: "Fitbit"),
        ServiceType(identifier: 254, objectTypes: [], name: "Garmin"),
        ServiceType(identifier: 260, objectTypes: [], name: "Apple Health"),
        ServiceType(identifier: 284, objectTypes: [], name: "GoogleFit"),
    ]
    
    static let entertainment = [
        ServiceType(identifier: 16, objectTypes: [], name: "Spotify"),
        ServiceType(identifier: 281, objectTypes: [], name: "YouTube"),
    ]
    
    static let data: [ServiceGroupType] = [
        ServiceGroupType(identifier: 1, serviceTypes: social, name: "Social"),
        ServiceGroupType(identifier: 2, serviceTypes: medical, name: "Medical"),
        ServiceGroupType(identifier: 3, serviceTypes: finance, name: "Finance"),
        ServiceGroupType(identifier: 4, serviceTypes: fitness, name: "Health & Fitness"),
        ServiceGroupType(identifier: 5, serviceTypes: entertainment, name: "Entertainment"),
    ]
}

enum TestDailyActivity {
	static let last30Days: [FitnessActivitySummary] = [
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 8), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 9), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 10), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 11), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 12), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 13), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 14), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 15), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 16), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 17), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 18), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 19), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 20), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 21), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 22), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 23), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 24), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 25), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 26), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 27), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 28), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 29), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 30), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5, day: 31), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 6, day: 1), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 6, day: 2), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 6, day: 3), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 6, day: 4), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 6, day: 5), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 6, day: 6), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
	]
	
	static var last30DaysTotal: Int {
		last30Days.map { Int($0.steps) }.reduce(0, +)
	}

	static var last30DaysAverage: Double {
		Double(last30DaysTotal / last30Days.count)
	}
	
	static let allTime: [FitnessActivitySummary] = [
		FitnessActivitySummary(startDate: Date.date(year: 2021, month: 7), endDate: Date.date(year: 2021, month: 7), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2021, month: 8), endDate: Date.date(year: 2021, month: 8), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2021, month: 9), endDate: Date.date(year: 2021, month: 9), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2021, month: 10), endDate: Date.date(year: 2021, month: 10), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2021, month: 11), endDate: Date.date(year: 2021, month: 11), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2021, month: 12), endDate: Date.date(year: 2021, month: 12), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 1), endDate: Date.date(year: 2022, month: 1), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 2), endDate: Date.date(year: 2022, month: 2), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 3), endDate: Date.date(year: 2022, month: 3), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 4), endDate: Date.date(year: 2022, month: 4), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 5), endDate: Date.date(year: 2022, month: 5), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
		FitnessActivitySummary(startDate: Date.date(year: 2022, month: 6), endDate: Date.date(year: 2022, month: 6), steps: Double.random(in: 1...999), distances: [FitnessActivitySummary.Distances(activity: "", distance: Double.random(in: 1...999))], calories: Double.random(in: 1...999), activity: Int(Double.random(in: 1...999))),
	]
	
	static var allTimeTotal: Int {
		allTime.map { Int($0.steps) }.reduce(0, +)
	}

	static var allTimeDailyAverage: Int {
		allTime.map { Int($0.steps) }.reduce(0, +) / allTime.count
	}
}

enum TestDiscoveryObjects {
    static let sections: [ServiceSection] = {
        guard let url = Bundle.main.url(forResource: "discovery", withExtension: "json"),
              let jsonData = try? Data(contentsOf: url),
              let serviceInfo = try? JSONDecoder().decode(ServicesInfo.self, from: jsonData) else {
            return []
        }
        
        let services = serviceInfo.services
        
        let serviceGroupIds = Set(services.flatMap { $0.serviceGroupIds })
        let serviceGroups = serviceInfo.serviceGroups.filter { serviceGroupIds.contains($0.identifier) }
        
        var sections = [ServiceSection]()
        serviceGroups.forEach { group in
            let items = services
                .filter { $0.serviceGroupIds.contains(group.identifier) }
                .sorted { $0.name < $1.name }
            sections.append(ServiceSection(serviceGroupId: group.identifier, title: group.name, items: items))
        }
        
        sections.sort { $0.serviceGroupId < $1.serviceGroupId }
        return sections
    }()
}
