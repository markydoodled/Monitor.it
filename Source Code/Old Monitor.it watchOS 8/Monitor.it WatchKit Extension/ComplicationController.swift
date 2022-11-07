//
//  ComplicationController.swift
//  Monitor.it WatchKit Extension
//
//  Created by Mark Howard on 26/09/2021.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "Monitor.it", supportedFamilies: [.circularSmall, .modularSmall, .utilitarianSmall, .utilitarianLarge, .extraLarge, .graphicCorner, .graphicCircular, .graphicExtraLarge, .modularLarge])
            // Multiple complication support can be added here with more descriptors
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        handler(createTimelineEntry(forComplication: complication, date: Date()))
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after the given date
        handler(nil)
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let future = Date().addingTimeInterval(25.0 * 60.0 * 60.0)
        let template = createTemplate(forComplication: complication, date: future)
        handler(template)
    }
    private func createTimelineEntry(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry {
            
            // Get the correct template based on the complication.
            let template = createTemplate(forComplication: complication, date: date)
            
            // Use the template and date to create a timeline entry.
            return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        }
        private func createTemplate(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTemplate {
            switch complication.family {
            case .modularSmall:
                return createModularSmallTemplate(forDate: date)
            case .modularLarge:
                return createModularLargeTemplate(forDate: date)
            case .utilitarianSmall, .utilitarianSmallFlat:
                return createUtilitarianSmallFlatTemplate(forDate: date)
            case .utilitarianLarge:
                return createUtilitarianLargeTemplate(forDate: date)
            case .circularSmall:
                return createCircularSmallTemplate(forDate: date)
            case .extraLarge:
                return createExtraLargeTemplate(forDate: date)
            case .graphicCorner:
                return createGraphicCornerTemplate(forDate: date)
            case .graphicCircular:
                return createGraphicCircleTemplate(forDate: date)
            case .graphicRectangular:
                return createGraphicRectangularTemplate(forDate: date)
            case .graphicBezel:
                return createGraphicBezelTemplate(forDate: date)
            case .graphicExtraLarge:
                if #available(watchOSApplicationExtension 7.0, *) {
                    return createGraphicExtraLargeTemplate(forDate: date)
                } else {
                    fatalError("Graphic Extra Large template is only available on watchOS 7.")
                }
            @unknown default:
                fatalError("*** Unknown Complication Family ***")
            }
        }
        // Return a modular small template.
        private func createModularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
            // Create the data providers.
            let image = CLKImageProvider(onePieceImage: UIImage(named: "Complications/Modular") ?? UIImage())
            
            // Create the template using the providers.
            let template = CLKComplicationTemplateModularSmallSimpleImage(imageProvider: image)
            return template
        }

        // Return a modular large template.
        private func createModularLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
            // Create the data providers.
            let titleTextProvider = CLKSimpleTextProvider(text: "Monitor.it", shortText: "Moni")
            titleTextProvider.tintColor = .init(red: 0.364, green: 0.356, blue: 0.894, alpha: 100)

            let textLine1 = CLKSimpleTextProvider(text: "Monitor")
            let combinedText1 = CLKTextProvider(format: "%@", textLine1)
                   
            let textLine3 = CLKSimpleTextProvider(text: "Health")
            let combinedText2 = CLKTextProvider(format: "%@", textLine3)
            
            // Create the template using the providers.
            let template = CLKComplicationTemplateModularLargeStandardBody(headerTextProvider: titleTextProvider, body1TextProvider: combinedText1, body2TextProvider: combinedText2)
            return template
        }

        // Return a utilitarian small flat template.
        private func createUtilitarianSmallFlatTemplate(forDate date: Date) -> CLKComplicationTemplate {
            // Create the data providers.
            let image = CLKImageProvider(onePieceImage: UIImage(named: "Complications/Utilitarian")!)
            
            // Create the template using the providers.
            let template = CLKComplicationTemplateUtilitarianSmallRingImage(imageProvider: image, fillFraction: Float(100), ringStyle: .closed)
            return template
        }


        // Return a utilitarian large template.
        private func createUtilitarianLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
            // Create the data providers.
            let solText = CLKSimpleTextProvider(text: "Monitor.it")
            let combinedText = CLKTextProvider(format: "%@", solText)
            
            // Create the template using the providers.
            let template = CLKComplicationTemplateUtilitarianLargeFlat(textProvider: combinedText)
            return template
        }

        // Return a circular small template.
        private func createCircularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
            // Create the data providers.
            let image = CLKImageProvider(onePieceImage: UIImage(named: "Complications/Circular")!)
            
            // Create the template using the providers.
            let template = CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: image)
            return template
        }

        // Return an extra large template.
        private func createExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
            // Create the data providers.
            let image = CLKImageProvider(onePieceImage: UIImage(named: "Complications/ExtraLarge")!)
            
            // Create the template using the providers.
            let template = CLKComplicationTemplateExtraLargeSimpleImage(imageProvider: image)
            return template
        }

        // Return a graphic template that fills the corner of the watch face.
        private func createGraphicCornerTemplate(forDate date: Date) -> CLKComplicationTemplate {
            // Create the data providers.
            let image = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complications/GraphicCorner")!)
            
            // Create the template using the providers.
            let template = CLKComplicationTemplateGraphicCornerCircularImage(imageProvider: image)
            return template
        }

        // Return a graphic circle template.
        private func createGraphicCircleTemplate(forDate date: Date) -> CLKComplicationTemplate {
            // Create the data providers.
            let image = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complications/GraphicCircular")!)
            
            
            // Create the template using the providers.
            let template = CLKComplicationTemplateGraphicCircularImage(imageProvider: image)
            return template
        }

        // Return a large rectangular graphic template.
        private func createGraphicRectangularTemplate(forDate date: Date) -> CLKComplicationTemplate {
            // Create the data providers.
            let image = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complications/GraphicExtraLarge")!)
            
            // Create the template using the providers.
            let template = CLKComplicationTemplateGraphicRectangularFullImage(imageProvider: image)
            return template
        }

        // Return a circular template with text that wraps around the top of the watch's bezel.
        private func createGraphicBezelTemplate(forDate date: Date) -> CLKComplicationTemplate {
            
            // Create a graphic circular template with an image provider.
            let textline1 = CLKSimpleTextProvider(text: "Sol.")
            textline1.tintColor = .init(red: 0.364, green: 0.356, blue: 0.894, alpha: 100)
            let textLine2 = CLKSimpleTextProvider(text: "Sys.")
            let combinedText1 = CLKTextProvider(format: "%@", textline1)
            let combinedText2 = CLKTextProvider(format: "%@", textLine2)
            let circle = CLKComplicationTemplateGraphicCircularStackText(line1TextProvider: combinedText1, line2TextProvider: combinedText2)
            
            // Create the text provider.
            let solText = CLKSimpleTextProvider(text: "Solar")
            let sysText = CLKSimpleTextProvider(text: "System")
            let titleText = CLKTextProvider(format: "%@ %@", solText, sysText)
                   
            let numberOfCupsProvider = CLKSimpleTextProvider(text: "8")
            let cupsUnitProvider = CLKSimpleTextProvider(text: "Planets")
            let combinedCupsProvider = CLKTextProvider(format: "%@ %@", numberOfCupsProvider, cupsUnitProvider)
            
            let separator = NSLocalizedString(",", comment: "Separator for compound data strings.")
            let textProvider = CLKTextProvider(format: "%@%@ %@",
                                               titleText,
                                               separator,
                                               combinedCupsProvider)
            
            // Create the bezel template using the circle template and the text provider.
            let template = CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: circle, textProvider: textProvider)
            return template
        }

        // Returns an extra large graphic template
        @available(watchOSApplicationExtension 7.0, *)
        private func createGraphicExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
            
            // Create the data providers.
            let image = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complications/GraphicExtraLarge")!)
            
            return CLKComplicationTemplateGraphicExtraLargeCircularImage(imageProvider: image)
            
        }
}
